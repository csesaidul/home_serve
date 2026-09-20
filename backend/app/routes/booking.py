import logging
import os
from datetime import datetime

from fastapi import APIRouter, Depends, Header, HTTPException, Query, status
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from app.schemas.booking import BookingCreate, BookingReviewCreate, BookingStatusUpdate
from app.services.booking import create_booking, create_review, get_booking_by_id, get_booking_estimate, pay_booking, update_booking_status
from database import get_db

logger = logging.getLogger(__name__)
router = APIRouter(tags=["booking"])


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


@router.post("/booking")
def create_new_booking(payload: BookingCreate, db: Session = Depends(get_db)):
    try:
        booking = create_booking(
            db,
            client_id=payload.client_id,
            provider_id=payload.provider_id,
            category_id=payload.category_id,
            scheduled_at=payload.scheduled_at,
            address=payload.address,
        )
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(exc)) from exc
    return booking


@router.get("/booking/{booking_id}")
def get_booking(booking_id: int, db: Session = Depends(get_db)):
    booking = get_booking_by_id(db, booking_id)
    if booking is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
    return booking


@router.patch("/booking/{booking_id}/status")
def update_booking_status_endpoint(booking_id: int, status_value: str = Query(..., alias="status"), db: Session = Depends(get_db)):
    try:
        booking = update_booking_status(db, booking_id, status_value)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc
    if booking is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
    return booking


@router.get("/booking/{booking_id}/estimate")
def booking_estimate(booking_id: int, db: Session = Depends(get_db)):
    estimate = get_booking_estimate(db, booking_id)
    if estimate is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
    return estimate


@router.post("/booking/{booking_id}/review")
def create_booking_review(
    booking_id: int,
    payload: BookingReviewCreate,
    db: Session = Depends(get_db),
    authorization: str | None = Header(default=None, alias="Authorization"),
):
    user_id = _get_user_id_from_auth(authorization)
    try:
        review = create_review(db, booking_id, user_id, payload.rating, payload.comment)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc
    return review


@router.post("/booking/{booking_id}/pay")
def pay_booking_endpoint(
    booking_id: int,
    db: Session = Depends(get_db),
    authorization: str | None = Header(default=None, alias="Authorization"),
):
    user_id = _get_user_id_from_auth(authorization)
    try:
        booking = pay_booking(db, booking_id, user_id)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc
    if booking is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
    return booking
