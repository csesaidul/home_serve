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
