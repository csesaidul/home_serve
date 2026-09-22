import os
from datetime import datetime, timedelta

from fastapi.testclient import TestClient
from jose import jwt
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

from app.main import app
from database import Base, get_db


TEST_DATABASE_URL = "sqlite:///./test_home_serve.db"
engine = create_engine(
    TEST_DATABASE_URL,
    connect_args={"check_same_thread": False},
    future=True,
)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)


def create_tables():
    with engine.begin() as conn:
        conn.execute(text("DROP TABLE IF EXISTS reviews"))
        conn.execute(text("DROP TABLE IF EXISTS bookings"))
        conn.execute(text("DROP TABLE IF EXISTS service_categories"))
        conn.execute(text("DROP TABLE IF EXISTS provider_profiles"))
        conn.execute(text("DROP TABLE IF EXISTS client_profiles"))
        conn.execute(text("DROP TABLE IF EXISTS users"))
        conn.execute(
            text(
                """
                CREATE TABLE users (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name VARCHAR(120) NOT NULL,
                    gender VARCHAR(30),
                    phone VARCHAR(30) NOT NULL UNIQUE,
                    phone_verified BOOLEAN NOT NULL DEFAULT 0,
                    password_hash VARCHAR(255) NOT NULL,
                    is_admin BOOLEAN NOT NULL DEFAULT 0,
                    last_known_lat FLOAT,
                    last_known_lng FLOAT,
                    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """
            )
        )
        conn.execute(
            text(
                """
                CREATE TABLE client_profiles (
                    user_id INTEGER PRIMARY KEY,
                    verified BOOLEAN NOT NULL DEFAULT 0,
                    verified_at DATETIME
                )
                """
            )
        )
        conn.execute(
            text(
                """
                CREATE TABLE provider_profiles (
                    user_id INTEGER PRIMARY KEY,
                    bio TEXT,
                    skills TEXT,
                    categories TEXT,
                    portfolio TEXT,
                    status VARCHAR(20) NOT NULL DEFAULT 'pending',
                    verified BOOLEAN NOT NULL DEFAULT 0,
                    rating_avg NUMERIC(3,2) NOT NULL DEFAULT 0.00,
                    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """
            )
        )
        conn.execute(
            text(
                """
                CREATE TABLE service_categories (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name VARCHAR(100) NOT NULL UNIQUE,
                    icon VARCHAR(255),
                    base_price NUMERIC(10,2) NOT NULL
                )
                """
            )
        )
        conn.execute(
            text(
                """
                CREATE TABLE bookings (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    client_id INTEGER NOT NULL,
                    provider_id INTEGER NOT NULL,
                    category_id INTEGER NOT NULL,
                    status VARCHAR(20) NOT NULL DEFAULT 'requested',
                    scheduled_at DATETIME NOT NULL,
                    address VARCHAR(500) NOT NULL,
                    price_estimate NUMERIC(10,2),
                    payment_status VARCHAR(20) NOT NULL DEFAULT 'unpaid',
                    customer_notes TEXT,
                    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """
            )
        )
        conn.execute(
            text(
                """
                CREATE TABLE reviews (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    booking_id INTEGER NOT NULL UNIQUE,
                    rating INTEGER NOT NULL,
                    comment TEXT,
                    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """
            )
        )


def inject_seed_data():
    with SessionLocal() as db:
        db.execute(
            text(
                "INSERT INTO users (id, name, phone, password_hash, is_admin) "
                "VALUES (:id, :name, :phone, :password_hash, :is_admin)"
            ),
            {
                "id": 1,
                "name": "Admin User",
                "phone": "+1000",
                "password_hash": "x",
                "is_admin": True,
            },
        )
        db.execute(
            text(
                "INSERT INTO users (id, name, phone, password_hash, is_admin) "
                "VALUES (:id, :name, :phone, :password_hash, :is_admin)"
            ),
            {
                "id": 2,
                "name": "Client User",
                "phone": "+2000",
                "password_hash": "x",
                "is_admin": False,
            },
        )
        db.execute(
            text(
                "INSERT INTO users (id, name, phone, password_hash, is_admin) "
                "VALUES (:id, :name, :phone, :password_hash, :is_admin)"
            ),
            {
                "id": 3,
                "name": "Provider User",
                "phone": "+3000",
                "password_hash": "x",
                "is_admin": False,
            },
        )
        db.execute(
            text("INSERT INTO client_profiles (user_id, verified) VALUES (2, 1)"),
        )
        db.execute(
            text("INSERT INTO provider_profiles (user_id, verified, status) VALUES (3, 1, 'pending')"),
        )
        db.commit()


async def override_get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db


def get_auth_headers(user_id: int, is_admin: bool = False, provider_verified: bool = False, client_verified: bool = False):
    payload = {
        "user_id": user_id,
        "is_admin": is_admin,
        "provider_verified": provider_verified,
        "client_verified": client_verified,
        "exp": datetime.utcnow() + timedelta(minutes=30),
    }
    token = jwt.encode(payload, os.getenv("SECRET_KEY", "development-only-secret"), algorithm=os.getenv("ALGORITHM", "HS256"))
    return {"Authorization": f"Bearer {token}"}


def test_provider_and_category_endpoints():
    create_tables()
    inject_seed_data()
    client = TestClient(app)

    admin_headers = get_auth_headers(1, is_admin=True)
    response = client.post(
        "/admin/categories",
        json={"name": "Plumbing", "icon": "wrench", "base_price": 150.0},
        headers=admin_headers,
    )
    assert response.status_code == 200, response.text
    assert response.json()["name"] == "Plumbing"

    response = client.get("/categories")
    assert response.status_code == 200, response.text
    assert len(response.json()["items"]) >= 1

    provider_headers = get_auth_headers(3, provider_verified=True)
    response = client.post(
        "/provider/profile",
        json={
            "bio": "Experienced plumber",
            "skills": "pipe repair",
            "categories": "Plumbing",
            "portfolio": "https://example.com/portfolio",
        },
        headers=provider_headers,
    )
    assert response.status_code == 200, response.text
    assert response.json()["status"] == "pending"


def test_booking_flow():
    create_tables()
    inject_seed_data()
    client = TestClient(app)

    admin_headers = get_auth_headers(1, is_admin=True)
    client.post(
        "/admin/categories",
        json={"name": "Electrical", "icon": "bolt", "base_price": 200.0},
        headers=admin_headers,
    )

    client_id = 2
    provider_id = 3
    client_headers = get_auth_headers(client_id, client_verified=True)
    response = client.post(
        "/booking",
        json={
            "client_id": client_id,
            "provider_id": provider_id,
            "category_id": 1,
            "scheduled_at": "2026-09-20T10:00:00",
            "address": "123 Main St",
            "customer_notes": "Main circuit breaker keeps tripping under load in",
        },
        headers=client_headers,
    )
    assert response.status_code == 200, response.text
    booking_id = response.json()["id"]

    bookings = client.get("/booking", params={"client_id": client_id})
    assert bookings.status_code == 200, bookings.text
    assert bookings.json()["items"][0]["id"] == booking_id

    response = client.get(f"/booking/{booking_id}")
    assert response.status_code == 200, response.text
    assert response.json()["status"] == "requested"

    estimate = client.get(f"/booking/{booking_id}/estimate")
    assert estimate.status_code == 200, estimate.text
    assert estimate.json()["estimated_price"] == 200.0

    summary = client.get(f"/booking/{booking_id}/summary")
    assert summary.status_code == 200, summary.text
    assert summary.json()["payment"]["estimated_total"] == 250.0

    progress = client.get(f"/booking/{booking_id}/progress")
    assert progress.status_code == 200, progress.text
    assert len(progress.json()["steps"]) >= 3

    confirm = client.post(f"/booking/{booking_id}/confirm")
    assert confirm.status_code == 200, confirm.text
    assert confirm.json()["status"] == "accepted"

    provider_headers = get_auth_headers(provider_id, provider_verified=True)
    response = client.patch(
        f"/booking/{booking_id}/status",
        params={"status": "accepted"},
        headers=provider_headers,
    )
    assert response.status_code == 200, response.text
    assert response.json()["status"] == "accepted"

    response = client.patch(
        f"/booking/{booking_id}/status",
        params={"status": "completed"},
        headers=provider_headers,
    )
    assert response.status_code == 200, response.text
    assert response.json()["status"] == "completed"
