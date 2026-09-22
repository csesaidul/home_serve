from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.schemas.account import AddressCreate, AddressUpdate, NotificationSettingsUpdate
from app.services.account import (
    delete_address, get_client_home, list_addresses, list_client_bookings,
    list_provider_bookings, save_address, set_notification_setting, update_address,
)
from database import get_db

router = APIRouter(tags=["account"])


@router.get("/client/home/{user_id}")
def client_home(user_id: int, db: Session = Depends(get_db)):
    result = get_client_home(db, user_id)
    if result is None:
        raise HTTPException(status_code=404, detail="Client profile not found")
    return result


@router.get("/client/{user_id}/bookings")
def client_bookings(user_id: int, db: Session = Depends(get_db)):
    return {"items": list_client_bookings(db, user_id)}


@router.get("/provider/{user_id}/bookings")
def provider_bookings(user_id: int, db: Session = Depends(get_db)):
    return {"items": list_provider_bookings(db, user_id)}


@router.get("/client/{user_id}/addresses")
def client_addresses(user_id: int, db: Session = Depends(get_db)):
    return {"items": list_addresses(db, user_id)}


@router.post("/client/{user_id}/addresses", status_code=status.HTTP_201_CREATED)
def add_client_address(user_id: int, payload: AddressCreate, db: Session = Depends(get_db)):
    return save_address(db, user_id, payload.label, payload.address, payload.is_default)


@router.patch("/client/{user_id}/addresses/{address_id}")
def edit_client_address(user_id: int, address_id: int, payload: AddressUpdate, db: Session = Depends(get_db)):
    result = update_address(db, user_id, address_id, payload.label, payload.address, payload.is_default)
    if result is None:
        raise HTTPException(status_code=404, detail="Address not found")
    return result


@router.delete("/client/{user_id}/addresses/{address_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_client_address(user_id: int, address_id: int, db: Session = Depends(get_db)):
    if not delete_address(db, user_id, address_id):
        raise HTTPException(status_code=404, detail="Address not found")


@router.get("/client/{user_id}/settings")
def client_settings(user_id: int, db: Session = Depends(get_db)):
    row = db.execute(text("SELECT id AS user_id, sms_notifications_enabled FROM users WHERE id = :user_id"), {"user_id": user_id}).mappings().first()
    if row is None:
        raise HTTPException(status_code=404, detail="User not found")
    return dict(row)


@router.patch("/client/{user_id}/settings")
def update_client_settings(user_id: int, payload: NotificationSettingsUpdate, db: Session = Depends(get_db)):
    result = set_notification_setting(db, user_id, payload.sms_notifications_enabled)
    if result is None:
        raise HTTPException(status_code=404, detail="User not found")
    return result