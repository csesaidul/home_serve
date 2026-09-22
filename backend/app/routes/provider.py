import logging
import os
import re
from pathlib import Path

from fastapi import APIRouter, Depends, File, Form, Header, HTTPException, Query, Request, UploadFile, status
from jose import jwt, JWTError
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.schemas.account import ReviewCreate
from app.schemas.provider import CategoryCreate, ProviderApplicationUpdate, ProviderProfileCreate, PortfolioItemCreate
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
    create_portfolio_item, delete_portfolio_item, get_provider_application,
    get_provider_dashboard, submit_provider_application,
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


@router.get("/provider/application/{user_id}")
def provider_application(user_id: int, db: Session = Depends(get_db)):
    application = get_provider_application(db, user_id)
    if application is None:
        raise HTTPException(status_code=404, detail="Provider application not found")
    return application


@router.patch("/provider/application/{user_id}")
def update_provider_application(user_id: int, payload: ProviderApplicationUpdate, db: Session = Depends(get_db)):
    profile = upsert_provider_profile(db, user_id, payload.bio, payload.skills, payload.categories, None)
    db.execute(text("""UPDATE provider_profiles SET profile_photo = COALESCE(:profile_photo, profile_photo),
        location = COALESCE(:location, location), years_experience = COALESCE(:years_experience, years_experience),
        trade_certificate_url = COALESCE(:trade_certificate_url, trade_certificate_url) WHERE user_id = :user_id"""),
        {"user_id": user_id, "profile_photo": payload.profile_photo, "location": payload.location, "years_experience": payload.years_experience, "trade_certificate_url": payload.trade_certificate_url})
    db.commit()
    return get_provider_application(db, user_id) or profile


@router.post("/provider/application/{user_id}/submit")
def submit_application(user_id: int, db: Session = Depends(get_db)):
    result = submit_provider_application(db, user_id)
    if result is None:
        raise HTTPException(status_code=404, detail="Provider application not found")
    return result


@router.get("/provider/dashboard/{user_id}")
def provider_dashboard(user_id: int, db: Session = Depends(get_db)):
    result = get_provider_dashboard(db, user_id)
    if result is None:
        raise HTTPException(status_code=404, detail="Provider profile not found")
    return result


@router.post("/provider/{user_id}/portfolio", status_code=status.HTTP_201_CREATED)
def add_portfolio_item(user_id: int, payload: PortfolioItemCreate, db: Session = Depends(get_db)):
    return create_portfolio_item(db, user_id, payload.title, payload.description, payload.image_url, payload.category)


@router.delete("/provider/{user_id}/portfolio/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_portfolio_item(user_id: int, item_id: int, db: Session = Depends(get_db)):
    if not delete_portfolio_item(db, user_id, item_id):
        raise HTTPException(status_code=404, detail="Portfolio item not found")


@router.post("/client/{client_id}/bookings/{booking_id}/review", status_code=status.HTTP_201_CREATED)
def review_completed_booking(client_id: int, booking_id: int, payload: ReviewCreate, db: Session = Depends(get_db)):
    from app.services.provider import create_review

    try:
        review = create_review(db, booking_id, client_id, payload.rating, payload.comment)
    except Exception as exc:
        db.rollback()
        raise HTTPException(status_code=409, detail="A review may already exist for this booking") from exc
    if review is None:
        raise HTTPException(status_code=400, detail="Only completed bookings owned by the client can be reviewed")
    return review


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
