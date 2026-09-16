import os
from datetime import datetime, timedelta, timezone
from secrets import choice

import bcrypt
from jose import jwt
from sqlalchemy import text
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session


_mock_otps: dict[str, str] = {}


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def verify_password(password: str, password_hash: str) -> bool:
    return bcrypt.checkpw(password.encode("utf-8"), password_hash.encode("utf-8"))


def generate_mock_otp(phone: str) -> str:
    otp = "".join(choice("0123456789") for _ in range(6))
    _mock_otps[phone] = otp
    return otp


def verify_mock_otp(phone: str, otp_code: str) -> bool:
    if _mock_otps.get(phone) != otp_code:
        return False
    del _mock_otps[phone]
    return True


def mark_phone_verified(db: Session, phone: str) -> bool:
    result = db.execute(
        text("UPDATE users SET phone_verified = true WHERE phone = :phone"),
        {"phone": phone},
    )
    db.commit()
    return result.rowcount == 1


def create_access_token(user_id: int, client_verified: bool, provider_verified: bool, is_admin: bool) -> str:
    expires_minutes = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))
    expires_at = datetime.now(timezone.utc) + timedelta(minutes=expires_minutes)
    claims = {
        "user_id": user_id,
        "client_verified": client_verified,
        "provider_verified": provider_verified,
        "is_admin": is_admin,
        "exp": expires_at,
    }
    return jwt.encode(
        claims,
        os.getenv("SECRET_KEY", "development-only-secret"),
        algorithm=os.getenv("ALGORITHM", "HS256"),
    )


def register_user(db: Session, phone: str, name: str, gender: str | None, password: str) -> tuple[int, str]:
    try:
        result = db.execute(
            text(
                "INSERT INTO users (phone, name, gender, password_hash) "
                "VALUES (:phone, :name, :gender, :password_hash)"
            ),
            {
                "phone": phone,
                "name": name,
                "gender": gender,
                "password_hash": hash_password(password),
            },
        )
        user_id = result.lastrowid
        db.execute(text("INSERT INTO client_profiles (user_id) VALUES (:user_id)"), {"user_id": user_id})
        db.commit()
    except IntegrityError:
        db.rollback()
        raise

    return user_id, generate_mock_otp(phone)


def authenticate_user(db: Session, phone: str, password: str) -> dict | None:
    user = db.execute(
        text(
            "SELECT u.id, u.password_hash, u.is_admin, cp.verified AS client_verified, "
            "pp.verified AS provider_verified "
            "FROM users u "
            "LEFT JOIN client_profiles cp ON cp.user_id = u.id "
            "LEFT JOIN provider_profiles pp ON pp.user_id = u.id "
            "WHERE u.phone = :phone"
        ),
        {"phone": phone},
    ).mappings().first()

    if user is None or not verify_password(password, user["password_hash"]):
        return None

    return {
        "user_id": user["id"],
        "client_verified": bool(user["client_verified"]),
        "provider_verified": bool(user["provider_verified"]),
        "is_admin": bool(user["is_admin"]),
    }
