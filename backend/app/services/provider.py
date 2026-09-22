from sqlalchemy import text
from sqlalchemy.orm import Session


def upsert_provider_profile(db: Session, user_id: int, bio: str | None, skills: str | None, categories: str | None, portfolio: str | None) -> dict:
    existing = db.execute(
        text("SELECT user_id FROM provider_profiles WHERE user_id = :user_id"),
        {"user_id": user_id},
    ).fetchone()

    if existing:
        db.execute(
            text(
                "UPDATE provider_profiles SET bio = :bio, skills = :skills, categories = :categories, "
                "portfolio = :portfolio, status = 'pending', verified = false WHERE user_id = :user_id"
            ),
            {
                "user_id": user_id,
                "bio": bio,
                "skills": skills,
                "categories": categories,
                "portfolio": portfolio,
            },
        )
    else:
        db.execute(
            text(
                "INSERT INTO provider_profiles (user_id, bio, skills, categories, portfolio, status, verified) "
                "VALUES (:user_id, :bio, :skills, :categories, :portfolio, 'pending', false)"
            ),
            {
                "user_id": user_id,
                "bio": bio,
                "skills": skills,
                "categories": categories,
                "portfolio": portfolio,
            },
        )

    db.commit()
    row = db.execute(
        text(
            "SELECT user_id, bio, skills, categories, portfolio, status, verified, rating_avg "
            "FROM provider_profiles WHERE user_id = :user_id"
        ),
        {"user_id": user_id},
    ).mappings().first()
    return dict(row) if row else {}


def get_provider_profile(db: Session, user_id: int) -> dict | None:
    row = db.execute(
        text(
            "SELECT pp.user_id, u.name, u.phone, pp.bio, pp.skills, pp.categories, pp.portfolio, pp.status, pp.verified, pp.rating_avg "
            "FROM provider_profiles pp JOIN users u ON u.id = pp.user_id WHERE pp.user_id = :user_id"
        ),
        {"user_id": user_id},
    ).mappings().first()
    return dict(row) if row else None


def list_pending_providers(db: Session) -> list[dict]:
    rows = db.execute(
        text(
            "SELECT pp.user_id, u.name, u.phone, pp.bio, pp.skills, pp.categories, pp.portfolio, pp.status, pp.verified "
            "FROM provider_profiles pp JOIN users u ON u.id = pp.user_id WHERE pp.verified = false AND pp.status IN ('pending', 'submitted') "
            "ORDER BY pp.user_id"
        )
    ).mappings().all()
    return [dict(row) for row in rows]


def approve_provider(db: Session, user_id: int) -> dict | None:
    db.execute(
        text("UPDATE provider_profiles SET verified = true, status = 'approved' WHERE user_id = :user_id"),
        {"user_id": user_id},
    )
    db.commit()
    return get_provider_profile(db, user_id)


def get_categories(db: Session) -> list[dict]:
    rows = db.execute(
        text("SELECT id, name, icon, base_price FROM service_categories ORDER BY id")
    ).mappings().all()
    return [dict(row) for row in rows]


def list_providers(
    db: Session,
    category: str | None = None,
    search: str | None = None,
    sort: str = "rating",
    available_only: bool = False,
    min_price: float | None = None,
    max_price: float | None = None,
    limit: int = 20,
    offset: int = 0,
) -> tuple[list[dict], int]:
    conditions = ["pp.verified = true", "pp.status = 'approved'"]
    params: dict[str, object] = {"limit": limit, "offset": offset}
    if category:
        conditions.append("pp.categories LIKE :category")
        params["category"] = f"%{category}%"
    if search:
        conditions.append("(u.name LIKE :search OR pp.skills LIKE :search OR pp.location LIKE :search)")
        params["search"] = f"%{search}%"
    if available_only:
        conditions.append("pp.response_time IS NOT NULL")
    if min_price is not None:
        conditions.append("pp.starting_price >= :min_price")
        params["min_price"] = min_price
    if max_price is not None:
        conditions.append("pp.starting_price <= :max_price")
        params["max_price"] = max_price

    order_by = {
        "rating": "pp.rating_avg DESC, pp.user_id",
        "nearest": "pp.user_id",
        "price_low": "pp.starting_price ASC, pp.user_id",
        "price_high": "pp.starting_price DESC, pp.user_id",
    }.get(sort, "pp.rating_avg DESC, pp.user_id")
    where = " AND ".join(conditions)
    total = db.execute(text(f"SELECT COUNT(*) FROM provider_profiles pp JOIN users u ON u.id = pp.user_id WHERE {where}"), params).scalar_one()
    rows = db.execute(
        text(f"""SELECT pp.user_id, u.name, pp.profile_photo, pp.categories, pp.skills, pp.location,
            pp.rating_avg, pp.starting_price, pp.response_time, pp.job_success_pct, pp.verified,
            CASE WHEN pp.response_time IS NULL THEN false ELSE true END AS available
            FROM provider_profiles pp JOIN users u ON u.id = pp.user_id
            WHERE {where} ORDER BY {order_by} LIMIT :limit OFFSET :offset"""),
        params,
    ).mappings().all()
    return [dict(row) for row in rows], int(total)


def get_provider_screen_profile(db: Session, user_id: int) -> dict | None:
    profile = db.execute(
        text("""SELECT pp.user_id, u.name, pp.profile_photo, pp.bio, pp.skills, pp.categories,
            pp.location, pp.years_experience, pp.job_success_pct, pp.response_time,
            pp.starting_price, pp.rating_avg, pp.verified, pp.status
            FROM provider_profiles pp JOIN users u ON u.id = pp.user_id
            WHERE pp.user_id = :user_id AND pp.verified = true AND pp.status = 'approved'"""),
        {"user_id": user_id},
    ).mappings().first()
    if profile is None:
        return None
    result = dict(profile)
    result["portfolio"] = get_provider_portfolio(db, user_id)
    result["reviews"] = get_provider_reviews(db, user_id)["items"]
    return result


def get_provider_portfolio(db: Session, user_id: int) -> list[dict]:
    rows = db.execute(
        text("""SELECT id, provider_id, title, description, image_url, category, completed_at, sort_order
            FROM portfolio_items WHERE provider_id = :user_id ORDER BY sort_order, completed_at DESC, id"""),
        {"user_id": user_id},
    ).mappings().all()
    return [dict(row) for row in rows]


def get_provider_reviews(db: Session, user_id: int) -> dict:
    rows = db.execute(
        text("""SELECT r.id, r.rating, r.comment, r.created_at, u.name AS client_name,
            cp.profile_photo AS client_profile_photo
            FROM reviews r JOIN bookings b ON b.id = r.booking_id
            JOIN users u ON u.id = b.client_id
            LEFT JOIN client_profiles cp ON cp.user_id = b.client_id
            WHERE b.provider_id = :user_id ORDER BY r.created_at DESC"""),
        {"user_id": user_id},
    ).mappings().all()
    items = [dict(row) for row in rows]
    return {"items": items, "count": len(items)}


def create_category(db: Session, name: str, icon: str | None, base_price: float) -> dict:
    existing = db.execute(
        text("SELECT id, name, icon, base_price FROM service_categories WHERE name = :name"),
        {"name": name},
    ).mappings().first()
    if existing is not None:
        db.execute(
            text(
                "UPDATE service_categories SET icon = :icon, base_price = :base_price WHERE id = :id"
            ),
            {"id": existing["id"], "icon": icon, "base_price": base_price},
        )
        db.commit()
        updated = db.execute(
            text("SELECT id, name, icon, base_price FROM service_categories WHERE id = :id"),
            {"id": existing["id"]},
        ).mappings().first()
        return dict(updated)

    result = db.execute(
        text(
            "INSERT INTO service_categories (name, icon, base_price) VALUES (:name, :icon, :base_price)"
        ),
        {"name": name, "icon": icon, "base_price": base_price},
    )
    db.commit()
    category_id = result.lastrowid
    row = db.execute(
        text("SELECT id, name, icon, base_price FROM service_categories WHERE id = :id"),
        {"id": category_id},
    ).mappings().first()
    return dict(row)
