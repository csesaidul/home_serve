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


def get_category_by_id(db: Session, category_id: int) -> dict | None:
    row = db.execute(
        text("SELECT id, name, icon, base_price FROM service_categories WHERE id = :id"),
        {"id": category_id},
    ).mappings().first()
    return dict(row) if row else None


def create_category(db: Session, name: str, icon: str | None, base_price: float) -> dict:
    existing = db.execute(
        text("SELECT id, name, icon, base_price FROM service_categories WHERE name = :name"),
        {"name": name},
    ).mappings().first()
    if existing is not None:
        return dict(existing)

    result = db.execute(
        text(
            "INSERT INTO service_categories (name, icon, base_price) VALUES (:name, :icon, :base_price)"
        ),
        {"name": name, "icon": icon, "base_price": base_price},
    )
    db.commit()
    category_id = result.lastrowid
    return get_category_by_id(db, category_id) or {}


def update_category(db: Session, category_id: int, name: str, icon: str | None, base_price: float) -> dict | None:
    existing = get_category_by_id(db, category_id)
    if existing is None:
        return None

    db.execute(
        text(
            "UPDATE service_categories SET name = :name, icon = :icon, base_price = :base_price WHERE id = :id"
        ),
        {"id": category_id, "name": name, "icon": icon, "base_price": base_price},
    )
    db.commit()
    return get_category_by_id(db, category_id)


def delete_category(db: Session, category_id: int) -> bool:
    result = db.execute(
        text("DELETE FROM service_categories WHERE id = :id"),
        {"id": category_id},
    )
    db.commit()
    return result.rowcount > 0


def get_admin_stats(db: Session) -> dict:
    total_bookings = db.execute(text("SELECT COUNT(*) FROM bookings")).scalar() or 0
    active_users = db.execute(
        text(
            "SELECT COUNT(DISTINCT user_id) FROM ( "
            "SELECT client_id AS user_id FROM bookings "
            "UNION ALL "
            "SELECT provider_id AS user_id FROM bookings "
            "UNION ALL "
            "SELECT user_id FROM client_profiles "
            "UNION ALL "
            "SELECT user_id FROM provider_profiles "
            ")"
        )
    ).scalar() or 0
    pending_providers = db.execute(
        text("SELECT COUNT(*) FROM provider_profiles WHERE verified = false OR status = 'pending'")
    ).scalar() or 0
    return {
        "total_bookings": int(total_bookings),
        "active_users": int(active_users),
        "pending_providers": int(pending_providers),
    }
