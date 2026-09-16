import logging

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.schemas.auth import LoginRequest, RegisterRequest, VerifyOtpRequest
from app.services.auth import (
    authenticate_user,
    create_access_token,
    mark_phone_verified,
    register_user,
    verify_mock_otp,
)
from database import get_db


logger = logging.getLogger(__name__)
router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", status_code=status.HTTP_201_CREATED)
def register(payload: RegisterRequest, db: Session = Depends(get_db)):
    try:
        user_id, mock_otp = register_user(
            db,
            phone=payload.phone,
            name=payload.name,
            gender=payload.gender,
            password=payload.password,
        )
    except IntegrityError:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Phone number already registered")

    logger.info("Mock OTP for %s: %s", payload.phone, mock_otp)
    return {
        "user_id": user_id,
        "phone": payload.phone,
        "otp_sent": True,
        "mock_otp": mock_otp,
    }


@router.post("/verify-otp")
def verify_otp(payload: VerifyOtpRequest, db: Session = Depends(get_db)):
    if not verify_mock_otp(payload.phone, payload.otp_code):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired OTP")

    if not mark_phone_verified(db, payload.phone):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired OTP")

    return {"phone": payload.phone, "phone_verified": True}


@router.post("/login")
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    claims = authenticate_user(db, payload.phone, payload.password)
    if claims is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid phone or password")

    return {
        "access_token": create_access_token(**claims),
        "token_type": "bearer",
        "claims": claims,
    }
