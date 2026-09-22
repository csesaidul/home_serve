from pydantic import BaseModel, Field


class ProviderProfileCreate(BaseModel):
    bio: str | None = Field(default=None, max_length=2000)
    skills: str | None = Field(default=None, max_length=1000)
    categories: str | None = Field(default=None, max_length=500)
    portfolio: str | None = Field(default=None, max_length=2000)


class CategoryCreate(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    icon: str | None = Field(default=None, max_length=255)
    base_price: float = Field(gt=0)


class ProviderApplicationUpdate(BaseModel):
    bio: str | None = Field(default=None, max_length=2000)
    skills: str | None = Field(default=None, max_length=1000)
    categories: str | None = Field(default=None, max_length=500)
    profile_photo: str | None = Field(default=None, max_length=500)
    location: str | None = Field(default=None, max_length=255)
    years_experience: int | None = Field(default=None, ge=0, le=100)
    trade_certificate_url: str | None = Field(default=None, max_length=500)


class ReviewCreate(BaseModel):
    rating: int = Field(ge=1, le=5)
    comment: str | None = Field(default=None, max_length=1000)
