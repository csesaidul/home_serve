import logging
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.schemas.booking import BookingCreate, BookingStatusUpdate
from app.services.booking import (
    confirm_booking,
    create_booking,
    get_booking_by_id,
    get_booking_estimate,
    get_booking_progress,
    get_booking_summary,
    update_booking_status,
)
from database import get_db

logger = logging.getLogger(__name__)
router = APIRouter(tags=["booking"])


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
            customer_notes=payload.customer_notes,
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


@router.get("/booking/{booking_id}/summary")
def booking_summary(booking_id: int, db: Session = Depends(get_db)):
    summary = get_booking_summary(db, booking_id)
    if summary is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
    return summary


@router.get("/booking/{booking_id}/progress")
def booking_progress(booking_id: int, db: Session = Depends(get_db)):
    progress = get_booking_progress(db, booking_id)
    if progress is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
    return progress


@router.post("/booking/{booking_id}/confirm")
def booking_confirm(booking_id: int, db: Session = Depends(get_db)):
    confirmed = confirm_booking(db, booking_id)
    if confirmed is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
    return confirmed
