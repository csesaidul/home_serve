from datetime import datetime

from sqlalchemy import text
from sqlalchemy.orm import Session


VALID_BOOKING_STATUSES = ["requested", "accepted", "en_route", "completed"]


def create_booking(db: Session, client_id: int, provider_id: int, category_id: int, scheduled_at: datetime, address: str, customer_notes: str | None = None) -> dict:
    category = db.execute(
        text("SELECT id, name, base_price FROM service_categories WHERE id = :category_id"),
        {"category_id": category_id},
    ).mappings().first()
    if category is None:
        raise ValueError("Category not found")

    result = db.execute(
        text(
            "INSERT INTO bookings (client_id, provider_id, category_id, status, scheduled_at, address, price_estimate, customer_notes) "
            "VALUES (:client_id, :provider_id, :category_id, 'requested', :scheduled_at, :address, :price_estimate, :customer_notes)"
        ),
        {
            "client_id": client_id,
            "provider_id": provider_id,
            "category_id": category_id,
            "scheduled_at": scheduled_at,
            "address": address,
            "price_estimate": category["base_price"],
            "customer_notes": customer_notes,
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
            "b.status, b.scheduled_at, b.address, b.price_estimate, b.payment_status, b.created_at, b.customer_notes "
            "FROM bookings b JOIN service_categories c ON c.id = b.category_id WHERE b.id = :booking_id"
        ),
        {"booking_id": booking_id},
    ).mappings().first()
    return dict(row) if row else None


def list_bookings_for_client(db: Session, client_id: int) -> list[dict]:
    rows = db.execute(
        text(
            "SELECT b.id, b.provider_id, b.category_id, c.name AS category_name, "
            "u.name AS provider_name, b.status, b.scheduled_at, b.address, "
            "b.price_estimate, b.payment_status, b.customer_notes "
            "FROM bookings b "
            "JOIN service_categories c ON c.id = b.category_id "
            "JOIN users u ON u.id = b.provider_id "
            "WHERE b.client_id = :client_id "
            "ORDER BY b.scheduled_at DESC, b.id DESC"
        ),
        {"client_id": client_id},
    ).mappings().all()
    return [dict(row) for row in rows]


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


def get_booking_summary(db: Session, booking_id: int) -> dict | None:
    booking = get_booking_by_id(db, booking_id)
    if booking is None:
        return None
    estimate = get_booking_estimate(db, booking_id)
    estimated_total = float(estimate["estimated_price"]) if estimate else float(booking.get("price_estimate") or 0)
    provider = db.execute(
        text("SELECT u.name, pp.rating_avg, pp.verified, pp.location, pp.categories FROM users u JOIN provider_profiles pp ON pp.user_id = u.id WHERE u.id = :provider_id"),
        {"provider_id": booking["provider_id"]},
    ).mappings().first()
    return {
        "booking_id": booking["id"],
        "provider_id": booking["provider_id"],
        "category_name": booking["category_name"],
        "scheduled_at": booking["scheduled_at"],
        "address": booking["address"],
        "customer_notes": booking.get("customer_notes") or "",
        "status": booking["status"],
        "provider": {
            "name": provider["name"] if provider else None,
            "rating": float(provider["rating_avg"]) if provider and provider["rating_avg"] is not None else 4.9,
            "verified": bool(provider["verified"]) if provider else True,
            "location": provider["location"] if provider else None,
            "specialty": provider["categories"] if provider else None,
        },
        "payment": {
            "base_inspection_charge": estimated_total,
            "safety_and_platform_fee": 50.0,
            "estimated_total": estimated_total + 50.0,
            "payment_mode": "post-pay",
        },
    }


def get_booking_progress(db: Session, booking_id: int) -> dict | None:
    booking = get_booking_by_id(db, booking_id)
    if booking is None:
        return None
    status_order = [
        ("requested", "Request Created", "done"),
        ("accepted", "Contacting Technician", "in_progress"),
        ("en_route", "Technician En Route", "pending"),
        ("completed", "Booking Confirmed", "pending"),
    ]
    steps = []
    current_index = next((i for i, (value, _, _) in enumerate(status_order) if value == booking["status"]), 0)
    for idx, (value, label, state) in enumerate(status_order):
        if idx < current_index:
            step_state = "done"
        elif idx == current_index:
            step_state = "in_progress"
        else:
            step_state = "pending"
        steps.append({"status": value, "label": label, "state": step_state})
    return {"booking_id": booking_id, "current_status": booking["status"], "steps": steps}


def confirm_booking(db: Session, booking_id: int) -> dict | None:
    booking = get_booking_by_id(db, booking_id)
    if booking is None:
        return None
    if booking["status"] == "requested":
        return update_booking_status(db, booking_id, "accepted")
    return booking
