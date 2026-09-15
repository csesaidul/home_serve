# HomeServe MVP — Task Checklist: Rabbi (Backend Developer)

**Plan & task breakdown by:** [Saidul Islam](https://github.com/csesaidul)

**Sprint:** September 15–19, 2026

**Role:** Backend Developer (FastAPI + XAMPP/MySQL)

> ⚠️ **Rule:** If a task is not completed by its deadline, the **Team Lead (Saidul Islam)** will complete it — and the credit for that task will then go to the **Team Lead**. Hitting every deadline matters, since the next day's UI work depends directly on these APIs.

---

## Day 1 — Tuesday, September 15

- [ ] **D1-T3 — XAMPP + MySQL setup and FastAPI project skeleton**
  - **Deadline:** 8:00 PM
  - **Depends on:** None
  - **Details:**
    - Install XAMPP, start the MySQL service, create the database: `homeserve_db`
    - Create the FastAPI project with a module-wise folder structure: `app/auth`, `app/booking`, `app/admin`, `app/core` (config, db connection), `app/models`
    - Set up the entrypoint in `app/main.py`, connect to MySQL via SQLAlchemy
    - Create `requirements.txt` (fastapi, uvicorn, sqlalchemy, pymysql, python-jose, passlib, etc.)
    - Push the skeleton to the repo

- [ ] **D1-T4 — DB migration scripts (Schema v0.1)**
  - **Deadline:** 8:00 PM
  - **Depends on:** D1-T1 (Sajib's ER diagram draft — you can start as soon as the draft is ready, no need to wait for the final version)
  - **Details:**
    - Create tables: `users` (id, name, gender, phone, phone_verified, password_hash, is_admin, last_known_lat, last_known_lng), `client_profiles`, `provider_profiles` (bio, skills, categories, portfolio, verified, rating_avg), `service_categories` (id, name, icon, base_price), `bookings` (id, client_id, provider_id, category_id, status, scheduled_at), `reviews` (id, booking_id, rating, comment)
    - Write the migration using Alembic (or a raw SQL script)
    - Run the migration on a fresh database to verify it works

---

## Day 2 — Wednesday, September 16

- [ ] **D2-T1 — Auth API**
  - **Deadline:** 8:00 PM
  - **Depends on:** D1-T3, D1-T4
  - **Details:**
    - `POST /auth/register` — body: phone, name, gender, password → creates the user, hashes the password with bcrypt, generates a mock OTP and shows it in the console/response (not AWS SNS — just a fixed/random code for testing)
    - `POST /auth/verify-otp` — body: phone, otp_code → sets `phone_verified = true` on match
    - `POST /auth/login` — body: phone, password → returns a JWT with claims `{user_id, client_verified, provider_verified, is_admin}`
    - Keep the JWT secret key and expiry configurable via `.env`

---

## Day 3 — Thursday, September 17

- [ ] **D3-T1 — Provider profile + category API**
  - **Deadline:** 8:00 PM
  - **Depends on:** D2-T1
  - **Details:**
    - `POST /provider/profile` — takes bio, skills, categories, portfolio, creates a `provider_profiles` entry with status = pending
    - `GET /provider/profile/{user_id}` — returns a specific provider's profile
    - `POST /admin/provider/{id}/approve` — admin-only, sets `verified = true`
    - `GET /categories` — lists all categories
    - `POST /admin/categories` — admin-only, adds a new category

- [ ] **D3-T2 — Booking API**
  - **Deadline:** 8:00 PM
  - **Depends on:** D2-T1
  - **Details:**
    - `POST /booking` — takes client_id, provider_id, category_id, scheduled_at, address, creates the booking with status = "requested"
    - `GET /booking/{id}` — returns booking details
    - `PATCH /booking/{id}/status` — provider-only, updates status (accepted → en_route → completed)
    - `GET /booking/{id}/estimate` — returns a price estimate based on the category's base_price

---

## Day 4 — Friday, September 18

- [ ] **D4-T1 — Review + payment API**
  - **Deadline:** 8:00 PM
  - **Depends on:** D3-T2
  - **Details:**
    - `POST /booking/{id}/review` — takes rating, comment, creates a review; reject if booking status isn't completed
    - `POST /booking/{id}/pay` — simulated payment, sets `payment_status = paid`

- [ ] **D4-T2 — Admin API**
  - **Deadline:** 8:00 PM
  - **Depends on:** D3-T1
  - **Details:**
    - `GET /admin/providers/pending` — list of providers awaiting approval
    - Complete the category CRUD endpoints (add edit/delete if missing)
    - `GET /admin/stats` — total booking count, active user count (basic counts)

---

## Day 5 — Saturday, September 19

- [ ] **D5-T1 — End-to-end integration testing** *(whole team together)*
  - **Deadline:** 2:00 PM
  - **Depends on:** All Day 1–4 tasks
  - **Details:** Test all APIs together with the Flutter app, check edge cases for every endpoint (bad input, missing resources)

- [ ] **D5-T2 — Backend deployment prep**
  - **Deadline:** 4:00 PM
  - **Depends on:** D5-T1
  - **Details:**
    - Move DB credentials and the JWT secret into a `.env` file (remove any hardcoded values)
    - Run the backend in a production-like config and verify it works
    - Document the run command in the README: `uvicorn app.main:app --host 0.0.0.0 --port 8000`

---

## Git Workflow — How to Submit Work

**Branch naming format:** `rabbi/<task-id>-<short-name>`
Example: `rabbi/D1-T3-fastapi-setup`, `rabbi/D3-T2-booking-api`

```bash
# 1. Clone the repo (first time only)
 git clone https://github.com/csesaidul/home_serve.git
 cd home_serve

# 3. Update local main before starting new work
git checkout main
git pull origin main

# 2. Create a new branch off main (task ID + name)
git checkout -b rabbi/D1-T3-fastapi-setup

# 4. Do the work, then commit
git add .
git commit -m "D1-T3: FastAPI project skeleton + XAMPP MySQL setup"

# 5. Push the branch and open a Pull Request
git push origin rabbi/D1-T3-fastapi-setup
# On GitHub, open a PR from this branch into main
# Include the task ID (e.g. D1-T3) in the PR title/description

# 6. For the next task, repeat from step 1 (update) — new branch, new work
```

- Every task needs its **own branch** and its **own PR** — never mix multiple tasks into one PR.
- After a PR is sent, the **Team Lead (Saidul)** will review the code and merge it into `main`.
- The task is not considered "done" until it's merged — and Saidul's UI work depends directly on these APIs, so any delay blocks the whole chain.
