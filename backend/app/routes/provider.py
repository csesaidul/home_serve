import logging
import os
import re
from pathlib import Path

from fastapi import APIRouter, Depends, File, Form, Header, HTTPException, Query, Request, UploadFile, status
from jose import jwt, JWTError
from sqlalchemy.orm import Session

from app.schemas.provider import CategoryCreate, ProviderProfileCreate
from app.services.provider import (
    approve_provider,
    create_category,
    get_categories,
    get_provider_profile,
    list_pending_providers,
    get_provider_portfolio,
    get_provider_reviews,
    get_provider_screen_profile,
    list_providers,
    upsert_provider_profile,
)
from database import get_db

logger = logging.getLogger(__name__)
router = APIRouter(tags=["provider", "admin"])
ICON_DIR = Path(__file__).resolve().parent.parent / "static" / "icons"


def _category_icon_filename(category_name: str, uploaded_filename: str) -> str:
    category_slug = re.sub(r"[^a-zA-Z0-9]+", "-", category_name).strip("-").lower()
    extension = Path(uploaded_filename).suffix.lower()
    return f"{category_slug}{extension}"


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


@router.get("/providers")
def discover_providers(
    category: str | None = None,
    search: str | None = None,
    sort: str = Query(default="rating", pattern="^(rating|nearest|price_low|price_high)$"),
    available_only: bool = False,
    min_price: float | None = Query(default=None, ge=0),
    max_price: float | None = Query(default=None, ge=0),
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    db: Session = Depends(get_db),
):
    items, total = list_providers(db, category, search, sort, available_only, min_price, max_price, limit, offset)
    return {"items": items, "count": len(items), "total": total, "offset": offset, "limit": limit}


@router.get("/providers/{user_id}")
def provider_screen_profile(user_id: int, db: Session = Depends(get_db)):
    profile = get_provider_screen_profile(db, user_id)
    if profile is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Provider not found")
    return profile


@router.get("/providers/{user_id}/portfolio")
def provider_portfolio(user_id: int, db: Session = Depends(get_db)):
    profile = get_provider_screen_profile(db, user_id)
    if profile is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Provider not found")
    items = get_provider_portfolio(db, user_id)
    return {"items": items, "count": len(items)}


@router.get("/providers/{user_id}/reviews")
def provider_reviews(user_id: int, db: Session = Depends(get_db)):
    profile = get_provider_screen_profile(db, user_id)
    if profile is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Provider not found")
    return get_provider_reviews(db, user_id)


@router.get("/categories")
def list_categories(db: Session = Depends(get_db)):
    categories = get_categories(db)
    return {"items": categories, "count": len(categories)}


@router.post("/admin/categories")
async def add_category(
    request: Request,
    name: str | None = Form(default=None, min_length=1, max_length=100),
    base_price: float | None = Form(default=None, gt=0),
    icon: UploadFile | None = File(default=None),
    db: Session = Depends(get_db),
):
    if request.headers.get("content-type", "").startswith("application/json"):
        payload = CategoryCreate.model_validate(await request.json())
        return create_category(db, payload.name, payload.icon, payload.base_price)

    if name is None or base_price is None or icon is None:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="name, base_price, and icon are required")

    if not icon.filename or Path(icon.filename).suffix.lower() not in {".png", ".jpg", ".jpeg", ".webp", ".gif"}:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Icon must be a PNG, JPG, WEBP, or GIF image")

    safe_filename = _category_icon_filename(name, icon.filename)
    ICON_DIR.mkdir(parents=True, exist_ok=True)
    icon_path = ICON_DIR / safe_filename
    icon_bytes = await icon.read()
    if not icon_bytes:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Icon file is empty")
    icon_path.write_bytes(icon_bytes)
    category = create_category(db, name, f"/static/icons/{safe_filename}", base_price)
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
