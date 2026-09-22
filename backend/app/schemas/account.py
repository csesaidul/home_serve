from pydantic import BaseModel, Field


class AddressCreate(BaseModel):
    label: str = Field(min_length=1, max_length=80)
    address: str = Field(min_length=1, max_length=500)
    is_default: bool = False


class AddressUpdate(BaseModel):
    label: str | None = Field(default=None, min_length=1, max_length=80)
    address: str | None = Field(default=None, min_length=1, max_length=500)
    is_default: bool | None = None


class NotificationSettingsUpdate(BaseModel):
    sms_notifications_enabled: bool


class ReviewCreate(BaseModel):
    rating: int = Field(ge=1, le=5)
    comment: str | None = Field(default=None, max_length=1000)