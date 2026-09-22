from sqlalchemy import text
from sqlalchemy.orm import Session


def get_client_profile(db: Session, user_id: int) -> dict | None:
    row = db.execute(
        text("""SELECT u.id AS user_id, u.name, u.gender, u.phone, u.email, cp.profile_photo,
            cp.address, cp.verified FROM users u JOIN client_profiles cp ON cp.user_id = u.id
            WHERE u.id = :user_id"""),
        {"user_id": user_id},
    ).mappings().first()
    return dict(row) if row else None


def update_client_profile(db: Session, user_id: int, name: str | None, gender: str | None, profile_photo: str | None, address: str | None, email: str | None = None) -> dict | None:
    if get_client_profile(db, user_id) is None:
        return None
    db.execute(
        text("UPDATE users SET name = COALESCE(:name, name), gender = COALESCE(:gender, gender), email = COALESCE(:email, email) WHERE id = :user_id"),
        {"user_id": user_id, "name": name, "gender": gender, "email": email},
    )
    db.execute(
        text("""UPDATE client_profiles SET profile_photo = COALESCE(:profile_photo, profile_photo),
            address = COALESCE(:address, address) WHERE user_id = :user_id"""),
        {"user_id": user_id, "profile_photo": profile_photo, "address": address},
    )
    db.commit()
    return get_client_profile(db, user_id)