from datetime import datetime

from sqlalchemy import text
from sqlalchemy.orm import Session


VALID_BOOKING_STATUSES = ["requested", "accepted", "en_route", "completed"]


def create_booking(db: Session, client_id: int, provider_id: int, category_id: int, scheduled_at: datetime, address: str) -> dict:
    category = db.execute(
        text("SELECT id, name, base_price FROM service_categories WHERE id = :category_id"),
        {"category_id": category_id},
    ).mappings().first()
    if category is None:
        raise ValueError("Category not found")

    result = db.execute(
        text(
            "INSERT INTO bookings (client_id, provider_id, category_id, status, scheduled_at, address, price_estimate) "
            "VALUES (:client_id, :provider_id, :category_id, 'requested', :scheduled_at, :address, :price_estimate)"
        ),
        {
            "client_id": client_id,
            "provider_id": provider_id,
            "category_id": category_id,
            "scheduled_at": scheduled_at,
            "address": address,
            "price_estimate": category["base_price"],
        },
    )
    db.commit()
    booking_id = result.lastrowid
    booking = get_booking_by_id(db, booking_id)
    return booking


def get_booking_by_id(db: Session, booking_id: int) -> dict | None:
    row = db.execute(
        text(
            "SELECT b.id, b.client_id, b.provider_id, b.category_id, c.name AS category_name, "
            "b.status, b.scheduled_at, b.address, b.price_estimate, b.payment_status, b.created_at "
            "FROM bookings b JOIN service_categories c ON c.id = b.category_id WHERE b.id = :booking_id"
        ),
        {"booking_id": booking_id},
    ).mappings().first()
    return dict(row) if row else None


def update_booking_status(db: Session, booking_id: int, next_status: str) -> dict | None:
    current = db.execute(
        text("SELECT status FROM bookings WHERE id = :booking_id"),
        {"booking_id": booking_id},
    ).scalar()
    if current is None:
        return None

    allowed = VALID_BOOKING_STATUSES
    if next_status not in allowed:
        raise ValueError("Invalid booking status")

    current_index = allowed.index(current)
    next_index = allowed.index(next_status)
    if next_index < current_index:
        raise ValueError("Status can only move forward")

    db.execute(
        text("UPDATE bookings SET status = :status WHERE id = :booking_id"),
        {"booking_id": booking_id, "status": next_status},
    )
    db.commit()
    return get_booking_by_id(db, booking_id)


def get_booking_estimate(db: Session, booking_id: int) -> dict | None:
    row = db.execute(
        text(
            "SELECT b.id, sc.base_price AS estimated_price, sc.name AS category_name "
            "FROM bookings b JOIN service_categories sc ON sc.id = b.category_id WHERE b.id = :booking_id"
        ),
        {"booking_id": booking_id},
    ).mappings().first()
    if row is None:
        return None
    return {"id": row["id"], "category_name": row["category_name"], "estimated_price": float(row["estimated_price"])}


def create_review(db: Session, booking_id: int, user_id: int, rating: int, comment: str | None) -> dict:
    booking = db.execute(
        text("SELECT client_id, provider_id, status FROM bookings WHERE id = :booking_id"),
        {"booking_id": booking_id},
    ).mappings().first()
    if booking is None:
        raise ValueError("Booking not found")
    if booking["status"] != "completed":
        raise ValueError("Review can only be created after booking is completed")
    if user_id not in (booking["client_id"], booking["provider_id"]):
        raise ValueError("User is not part of this booking")
    if rating < 1 or rating > 5:
        raise ValueError("Rating must be between 1 and 5")

    existing = db.execute(text("SELECT id FROM reviews WHERE booking_id = :booking_id"), {"booking_id": booking_id}).scalar()
    if existing is not None:
        raise ValueError("Review already exists for this booking")

    result = db.execute(
        text("INSERT INTO reviews (booking_id, rating, comment) VALUES (:booking_id, :rating, :comment)"),
        {"booking_id": booking_id, "rating": rating, "comment": comment},
    )
    db.commit()
    review_id = result.lastrowid
    row = db.execute(text("SELECT id, booking_id, rating, comment, created_at FROM reviews WHERE id = :id"), {"id": review_id}).mappings().first()
    return dict(row) if row else {}


def pay_booking(db: Session, booking_id: int, user_id: int) -> dict | None:
    booking = db.execute(
        text("SELECT id, client_id, provider_id, payment_status FROM bookings WHERE id = :booking_id"),
        {"booking_id": booking_id},
    ).mappings().first()
    if booking is None:
        raise ValueError("Booking not found")
    if user_id not in (booking["client_id"], booking["provider_id"]):
        raise ValueError("User is not part of this booking")

    db.execute(
        text("UPDATE bookings SET payment_status = 'paid' WHERE id = :booking_id"),
        {"booking_id": booking_id},
    )
    db.commit()
    return get_booking_by_id(db, booking_id)
