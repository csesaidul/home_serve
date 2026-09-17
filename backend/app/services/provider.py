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
    row = db.execute(
        text("SELECT id, name, icon, base_price FROM service_categories WHERE id = :id"),
        {"id": category_id},
    ).mappings().first()
    return dict(row)
