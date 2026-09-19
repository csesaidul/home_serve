from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.services.profile import get_client_profile, update_client_profile
from database import get_db


class ClientProfileUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=120)
    gender: str | None = Field(default=None, max_length=30)
    profile_photo: str | None = Field(default=None, max_length=500)
    address: str | None = Field(default=None, max_length=255)


router = APIRouter(tags=["profile"])


@router.get("/client/profile/{user_id}")
def client_profile(user_id: int, db: Session = Depends(get_db)):
    profile = get_client_profile(db, user_id)
    if profile is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Client profile not found")
    return profile


@router.patch("/client/profile/{user_id}")
def edit_client_profile(user_id: int, payload: ClientProfileUpdate, db: Session = Depends(get_db)):
    profile = update_client_profile(db, user_id, payload.name, payload.gender, payload.profile_photo, payload.address)
    if profile is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Client profile not found")
    return profile