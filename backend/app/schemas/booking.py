from datetime import datetime

from pydantic import BaseModel, Field


class BookingCreate(BaseModel):
    client_id: int
    provider_id: int
    category_id: int
    scheduled_at: datetime
    address: str = Field(min_length=1, max_length=500)


class BookingStatusUpdate(BaseModel):
    status: str = Field(min_length=1, max_length=20)
