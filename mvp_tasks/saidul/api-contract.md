# HomeServe MVP — API Contract (Release 1)

**Task:** D1-T6 | **Owner:** Saidul Islam | **For:** Rabbi's FastAPI backend (D2-T1, D3-T1, D3-T2, D4-T1, D4-T2)

**Base URL:** `http://localhost:8000`
**Auth:** Protected routes need header `Authorization: Bearer <access_token>` (token comes from `POST /auth/login`)

---

## Auth

### `POST /auth/register`
Creates a new user, hashes the password, sends a **mock OTP** (no real AWS SNS in MVP-1 — the code is returned directly for testing).

**Request body**
```json
{
  "phone": "01712345678",
  "name": "Rahim Uddin",
  "gender": "male",
  "password": "SecurePass123"
}
```
**Response — 201 Created**
```json
{
  "user_id": 101,
  "phone": "01712345678",
  "otp_sent": true,
  "mock_otp": "123456"
}
```
**Response — 409 Conflict** (phone already registered)
```json
{ "detail": "Phone number already registered" }
```

### `POST /auth/verify-otp`
Sets `phone_verified = true` when the OTP matches.

**Request body**
```json
{ "phone": "01712345678", "otp_code": "123456" }
```
**Response — 200 OK**
```json
{ "phone": "01712345678", "phone_verified": true }
```
**Response — 400 Bad Request**
```json
{ "detail": "Invalid or expired OTP" }
```

### `POST /auth/login`
Returns a JWT with capability claims, used for GoRouter route guarding (D2-T5).

**Request body**
```json
{ "phone": "01712345678", "password": "SecurePass123" }
```
**Response — 200 OK**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "claims": {
    "user_id": 101,
    "client_verified": true,
    "provider_verified": false,
    "is_admin": false
  }
}
```
**Response — 401 Unauthorized**
```json
{ "detail": "Invalid phone or password" }
```

---

## Provider

### `POST /provider/profile` 🔒
Creates a `provider_profiles` entry with `status = pending`.

**Request body**
```json
{
  "bio": "Experienced electrician, 5 years",
  "skills": ["wiring", "appliance repair"],
  "categories": [1, 3],
  "portfolio": ["https://example.com/img1.jpg"]
}
```
**Response — 201 Created**
```json
{ "provider_id": 55, "user_id": 101, "status": "pending", "verified": false }
```

### `GET /provider/profile/{user_id}` 🔒
Returns a provider's public profile.

**Response — 200 OK**
```json
{
  "provider_id": 55,
  "user_id": 101,
  "name": "Rahim Uddin",
  "bio": "Experienced electrician, 5 years",
  "skills": ["wiring", "appliance repair"],
  "categories": [1, 3],
  "portfolio": ["https://example.com/img1.jpg"],
  "verified": true,
  "rating_avg": 4.6
}
```
**Response — 404 Not Found**
```json
{ "detail": "Provider profile not found" }
```

### `POST /admin/provider/{id}/approve` 🔒 Admin only
Sets `verified = true` on the provider profile.

**Response — 200 OK**
```json
{ "provider_id": 55, "verified": true }
```
**Response — 403 Forbidden**
```json
{ "detail": "Admin access required" }
```

---

## Category

### `GET /categories`
Public. Returns all service categories (seeded by Sajib, D2-T3).

**Response — 200 OK**
```json
[
  { "id": 1, "name": "Electrician", "icon": "electrician.svg", "base_price": 300 },
  { "id": 2, "name": "Plumber", "icon": "plumber.svg", "base_price": 250 }
]
```

### `POST /admin/categories` 🔒 Admin only
Adds a new category.

**Request body**
```json
{ "name": "AC Repair", "icon": "ac_repair.svg", "base_price": 400 }
```
**Response — 201 Created**
```json
{ "id": 3, "name": "AC Repair", "icon": "ac_repair.svg", "base_price": 400 }
```

### `PUT /admin/categories/{id}` 🔒 Admin only
Edits an existing category.

**Request body**
```json
{ "name": "AC Repair & Service", "base_price": 450 }
```
**Response — 200 OK**
```json
{ "id": 3, "name": "AC Repair & Service", "icon": "ac_repair.svg", "base_price": 450 }
```

### `DELETE /admin/categories/{id}` 🔒 Admin only
Removes a category.

**Response — 204 No Content**

---

## Booking

### `POST /booking` 🔒
Creates a booking with `status = "requested"`.

**Request body**
```json
{
  "client_id": 101,
  "provider_id": 55,
  "category_id": 1,
  "scheduled_at": "2026-09-20T10:00:00Z",
  "address": "House 12, Road 4, Netrokona"
}
```
**Response — 201 Created**
```json
{
  "booking_id": 900,
  "status": "requested",
  "client_id": 101,
  "provider_id": 55,
  "category_id": 1,
  "scheduled_at": "2026-09-20T10:00:00Z",
  "address": "House 12, Road 4, Netrokona"
}
```

### `GET /booking/{id}` 🔒
Returns full booking details. Used by the Flutter status-polling screen (D4-T6, every 5 seconds).

**Response — 200 OK**
```json
{
  "booking_id": 900,
  "status": "accepted",
  "client_id": 101,
  "provider_id": 55,
  "category_id": 1,
  "scheduled_at": "2026-09-20T10:00:00Z",
  "address": "House 12, Road 4, Netrokona",
  "payment_status": "unpaid"
}
```

### `PATCH /booking/{id}/status` 🔒 Provider only
Valid transitions: `requested → accepted → en_route → completed`.

**Request body**
```json
{ "status": "accepted" }
```
**Response — 200 OK**
```json
{ "booking_id": 900, "status": "accepted" }
```
**Response — 403 Forbidden**
```json
{ "detail": "Only the assigned provider can update this booking" }
```

### `GET /booking/{id}/estimate` 🔒
Returns a price estimate based on the booking's category `base_price`.

**Response — 200 OK**
```json
{ "booking_id": 900, "estimated_price": 300, "currency": "BDT" }
```

---

## Review & Payment

### `POST /booking/{id}/review` 🔒
Only allowed when the booking's status is `completed`.

**Request body**
```json
{ "rating": 5, "comment": "Very professional, fixed it quickly." }
```
**Response — 201 Created**
```json
{ "review_id": 40, "booking_id": 900, "rating": 5, "comment": "Very professional, fixed it quickly." }
```
**Response — 400 Bad Request**
```json
{ "detail": "Booking must be completed before it can be reviewed" }
```

### `POST /booking/{id}/pay` 🔒
Simulated payment for MVP-1 (no real payment gateway). Sets `payment_status = paid`.

**Response — 200 OK**
```json
{ "booking_id": 900, "payment_status": "paid" }
```

---

## Admin

### `GET /admin/providers/pending` 🔒 Admin only
Feeds the Admin Panel's provider-approval list (D4-T5).

**Response — 200 OK**
```json
[
  { "provider_id": 55, "user_id": 101, "name": "Rahim Uddin", "submitted_at": "2026-09-16T12:00:00Z" }
]
```

### `GET /admin/stats` 🔒 Admin only
Basic counts for the admin dashboard.

**Response — 200 OK**
```json
{ "total_bookings": 42, "active_users": 130, "pending_providers": 3 }
```

---

## Quick Reference Table

| Method | Endpoint | Auth | Task |
|---|---|---|---|
| POST | `/auth/register` | — | D2-T1 |
| POST | `/auth/verify-otp` | — | D2-T1 |
| POST | `/auth/login` | — | D2-T1 |
| POST | `/provider/profile` | User | D3-T1 |
| GET | `/provider/profile/{user_id}` | User | D3-T1 |
| POST | `/admin/provider/{id}/approve` | Admin | D3-T1 |
| GET | `/categories` | — | D3-T1 |
| POST | `/admin/categories` | Admin | D3-T1 / D4-T2 |
| PUT | `/admin/categories/{id}` | Admin | D4-T2 |
| DELETE | `/admin/categories/{id}` | Admin | D4-T2 |
| POST | `/booking` | User | D3-T2 |
| GET | `/booking/{id}` | User | D3-T2 |
| PATCH | `/booking/{id}/status` | Provider | D3-T2 |
| GET | `/booking/{id}/estimate` | User | D3-T2 |
| POST | `/booking/{id}/review` | User | D4-T1 |
| POST | `/booking/{id}/pay` | User | D4-T1 |
| GET | `/admin/providers/pending` | Admin | D4-T2 |
| GET | `/admin/stats` | Admin | D4-T2 |
