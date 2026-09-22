from pydantic import BaseModel, Field


class RegisterRequest(BaseModel):
    phone: str = Field(min_length=3, max_length=30)
    name: str = Field(min_length=1, max_length=120)
    gender: str | None = Field(default=None, max_length=30)
    password: str = Field(min_length=8, max_length=128)


class VerifyOtpRequest(BaseModel):
    phone: str = Field(min_length=3, max_length=30)
    otp_code: str = Field(min_length=6, max_length=6, pattern=r"^\d{6}$")


class LoginRequest(BaseModel):
    phone: str = Field(min_length=3, max_length=30)
    password: str = Field(min_length=1, max_length=128)
