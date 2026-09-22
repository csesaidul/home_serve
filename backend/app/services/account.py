from sqlalchemy import text
from sqlalchemy.orm import Session


def get_client_home(db: Session, user_id: int) -> dict | None:
    profile = db.execute(text("""SELECT u.id AS user_id, u.name, u.phone, u.email,
        cp.profile_photo, cp.address, cp.verified FROM users u
        JOIN client_profiles cp ON cp.user_id = u.id WHERE u.id = :user_id"""),
        {"user_id": user_id}).mappings().first()
    if profile is None:
        return None
    stats = db.execute(text("""SELECT COUNT(*) AS total_bookings,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed_bookings,
        COALESCE(SUM(CASE WHEN payment_status = 'paid' THEN price_estimate ELSE 0 END), 0) AS total_spent
        FROM bookings WHERE client_id = :user_id"""), {"user_id": user_id}).mappings().one()
    return {"profile": dict(profile), "stats": dict(stats)}


def list_client_bookings(db: Session, user_id: int) -> list[dict]:
    rows = db.execute(text("""SELECT b.id, b.status, b.scheduled_at, b.address,
        b.price_estimate, b.payment_status, c.name AS category_name,
        b.provider_id, u.name AS provider_name, pp.profile_photo AS provider_photo,
        pp.rating_avg AS provider_rating FROM bookings b
        JOIN service_categories c ON c.id = b.category_id JOIN users u ON u.id = b.provider_id
        LEFT JOIN provider_profiles pp ON pp.user_id = b.provider_id
        WHERE b.client_id = :user_id ORDER BY b.scheduled_at DESC"""),
        {"user_id": user_id}).mappings().all()
    return [dict(row) for row in rows]


def list_provider_bookings(db: Session, user_id: int) -> list[dict]:
    rows = db.execute(text("""SELECT b.id, b.status, b.scheduled_at, b.address,
        b.price_estimate, b.payment_status, c.name AS category_name,
        b.client_id, u.name AS client_name, cp.profile_photo AS client_photo
        FROM bookings b JOIN service_categories c ON c.id = b.category_id
        JOIN users u ON u.id = b.client_id LEFT JOIN client_profiles cp ON cp.user_id = b.client_id
        WHERE b.provider_id = :user_id ORDER BY b.scheduled_at DESC"""),
        {"user_id": user_id}).mappings().all()
    return [dict(row) for row in rows]


def list_addresses(db: Session, user_id: int) -> list[dict]:
    rows = db.execute(text("SELECT id, label, address, is_default, created_at FROM saved_addresses WHERE user_id = :user_id ORDER BY is_default DESC, id"), {"user_id": user_id}).mappings().all()
    return [dict(row) for row in rows]


def save_address(db: Session, user_id: int, label: str, address: str, is_default: bool) -> dict:
    if is_default:
        db.execute(text("UPDATE saved_addresses SET is_default = false WHERE user_id = :user_id"), {"user_id": user_id})
    result = db.execute(text("INSERT INTO saved_addresses (user_id, label, address, is_default) VALUES (:user_id, :label, :address, :is_default)"), {"user_id": user_id, "label": label, "address": address, "is_default": is_default})
    db.commit()
    return dict(db.execute(text("SELECT id, label, address, is_default, created_at FROM saved_addresses WHERE id = :id"), {"id": result.lastrowid}).mappings().one())


def update_address(db: Session, user_id: int, address_id: int, label: str | None, address: str | None, is_default: bool | None) -> dict | None:
    existing = db.execute(text("SELECT id FROM saved_addresses WHERE id = :id AND user_id = :user_id"), {"id": address_id, "user_id": user_id}).first()
    if existing is None:
        return None
    if is_default:
        db.execute(text("UPDATE saved_addresses SET is_default = false WHERE user_id = :user_id"), {"user_id": user_id})
    db.execute(text("UPDATE saved_addresses SET label = COALESCE(:label, label), address = COALESCE(:address, address), is_default = COALESCE(:is_default, is_default) WHERE id = :id AND user_id = :user_id"), {"id": address_id, "user_id": user_id, "label": label, "address": address, "is_default": is_default})
    db.commit()
    return dict(db.execute(text("SELECT id, label, address, is_default, created_at FROM saved_addresses WHERE id = :id"), {"id": address_id}).mappings().one())


def delete_address(db: Session, user_id: int, address_id: int) -> bool:
    result = db.execute(text("DELETE FROM saved_addresses WHERE id = :id AND user_id = :user_id"), {"id": address_id, "user_id": user_id})
    db.commit()
    return result.rowcount == 1


def set_notification_setting(db: Session, user_id: int, enabled: bool) -> dict | None:
    result = db.execute(text("UPDATE users SET sms_notifications_enabled = :enabled WHERE id = :user_id"), {"user_id": user_id, "enabled": enabled})
    db.commit()
    if result.rowcount != 1:
        return None
    return {"user_id": user_id, "sms_notifications_enabled": enabled}