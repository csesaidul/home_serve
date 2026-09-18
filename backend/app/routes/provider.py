import logging
import os

from fastapi import APIRouter, Depends, Header, HTTPException, status
from jose import jwt, JWTError
from sqlalchemy.orm import Session

from app.schemas.provider import CategoryCreate, ProviderProfileCreate
from app.services.provider import (
    approve_provider,
    create_category,
    get_categories,
    get_provider_profile,
    list_pending_providers,
    upsert_provider_profile,
)
from database import get_db

logger = logging.getLogger(__name__)
router = APIRouter(tags=["provider", "admin"])


def _get_user_id_from_auth(authorization: str | None, user_id: int | None = None) -> int:
    if user_id is not None:
        return user_id
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing or invalid Authorization header")

    token = authorization.split(" ", 1)[1]
    try:
        payload = jwt.decode(
            token,
            os.getenv("SECRET_KEY", "development-only-secret"),
            algorithms=[os.getenv("ALGORITHM", "HS256")],
        )
    except JWTError as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token") from exc

    user_id_from_token = payload.get("user_id")
    if user_id_from_token is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token missing user_id claim")
    return int(user_id_from_token)


@router.post("/provider/profile")
def create_or_update_provider_profile(
    payload: ProviderProfileCreate,
    db: Session = Depends(get_db),
    authorization: str | None = Header(default=None, alias="Authorization"),
    user_id: int | None = None,
):
    resolved_user_id = _get_user_id_from_auth(authorization, user_id)
    profile = upsert_provider_profile(
        db,
        user_id=resolved_user_id,
        bio=payload.bio,
        skills=payload.skills,
        categories=payload.categories,
        portfolio=payload.portfolio,
    )
    return profile


@router.post("/provider/profile/{user_id}")
def create_provider_profile_for_user(user_id: int, payload: ProviderProfileCreate, db: Session = Depends(get_db)):
    profile = upsert_provider_profile(
        db,
        user_id=user_id,
        bio=payload.bio,
        skills=payload.skills,
        categories=payload.categories,
        portfolio=payload.portfolio,
    )
    return profile


@router.get("/provider/profile/{user_id}")
def get_provider_profile_by_user_id(user_id: int, db: Session = Depends(get_db)):
    profile = get_provider_profile(db, user_id)
    if profile is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found")
    return profile


@router.get("/categories")
def list_categories(db: Session = Depends(get_db)):
    categories = get_categories(db)
    return {"items": categories, "count": len(categories)}


@router.post("/admin/categories")
def add_category(payload: CategoryCreate, db: Session = Depends(get_db)):
    category = create_category(db, payload.name, payload.icon, payload.base_price)
    return category


@router.post("/admin/provider/{user_id}/approve")
def approve_provider_profile(user_id: int, db: Session = Depends(get_db)):
    profile = approve_provider(db, user_id)
    if profile is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found")
    return profile


@router.get("/admin/providers/pending")
def pending_providers(db: Session = Depends(get_db)):
    return {"items": list_pending_providers(db), "count": len(list_pending_providers(db))}
