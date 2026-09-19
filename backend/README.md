# HomeServe Backend

FastAPI backend for the HomeServe application.

## Prerequisites

- Python 3.10 or newer
- MySQL Server running locally or reachable from your machine
- Git, if you are cloning the project

## Setup

From the backend directory, create and activate a virtual environment:

### Windows PowerShell

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
```

If PowerShell blocks activation, allow scripts for the current user and run the activation command again:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\.venv\Scripts\Activate.ps1
```

Install the project dependencies:

```powershell
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

Create the environment file:

```powershell
Copy-Item .env.example .env
```

Edit `.env` and set at least these values:

```env
DATABASE_URL=mysql+mysqlconnector://root:your_password@localhost:3306/homeserve_db
SECRET_KEY=replace_with_a_long_random_secret
```

Create the MySQL database if it does not already exist:

```sql
CREATE DATABASE homeserve_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

The username, password, host, port, and database name in `DATABASE_URL` must match your MySQL installation. Do not commit `.env` or real credentials.

## Run Database Migrations

With the virtual environment active and MySQL running, apply the schema:

```powershell
python -m alembic upgrade head
```

To see the current migration revision:

```powershell
python -m alembic current
```

## Start the API

Start the development server with auto-reload:

```powershell
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

You can also start it through the application module:

```powershell
python app/main.py
```

The API is available at <http://localhost:8000>.

## Load Demo Provider Data

The repository includes the profile photos in `assets/profile_photos` and a rerunnable
seed script for the provider, client, and portfolio screens. Apply migrations first,
then run:

```powershell
python seed_data.py
```

The script creates 3 client accounts, 10 provider accounts, and 6 portfolio items.
Every demo account uses the password `homeserve-demo`.

### Demo Login Credentials

Use the phone number as the `phone` value for `/auth/login`:

| User ID | Role | Phone |
| ---: | --- | --- |
| 101 | Client - Nusrat Jahan | `+8801700000101` |
| 102 | Client - Farhan Tanvir | `+8801700000102` |
| 103 | Client - Maliha Rahman | `+8801700000103` |
| 201 | Provider - Rahul Hassan | `+8801800000201` |
| 202 | Provider - Master Rahim C. | `+8801800000202` |
| 203 | Provider - Priya Sen | `+8801800000203` |
| 204 | Provider - Tanvir Alam | `+8801800000204` |
| 205 | Provider - Ava Morgan | `+8801800000205` |
| 206 | Provider - Sofia Karim | `+8801800000206` |
| 207 | Provider - Rahim Uddin | `+8801800000207` |
| 208 | Provider - Maya Chen | `+8801800000208` |
| 209 | Provider - John Smith | `+8801800000209` |
| 210 | Provider - Priya Ahmed | `+8801800000210` |

Password for all accounts: `homeserve-demo`.
Photos are available from `/assets/profile_photos/...` while the API is running.

## Provider Screen APIs

The provider discovery and profile mockups use these endpoints:

| Endpoint | Purpose |
| --- | --- |
| `GET /providers?category=Electrician&sort=rating` | Provider list with search, price, availability, pagination, and sort filters |
| `GET /providers/{user_id}` | Full verified provider profile with portfolio and reviews |
| `GET /providers/{user_id}/portfolio` | Portfolio cards for the provider detail screen |
| `GET /providers/{user_id}/reviews` | Customer reviews for the provider detail screen |
| `GET /client/profile/{user_id}` | Client profile data |
| `PATCH /client/profile/{user_id}` | Update client profile data |

Supported provider sort values are `rating`, `nearest`, `price_low`, and `price_high`.
Use `available_only=true`, `min_price`, `max_price`, `search`, `limit`, and `offset`
as optional query parameters on `/providers`.

## Verify the Server

Open these URLs in a browser, or use them from another client:

- API status: <http://localhost:8000/>
- Database health check: <http://localhost:8000/api/health>
- Interactive Swagger documentation: <http://localhost:8000/docs>
- ReDoc documentation: <http://localhost:8000/redoc>
- OpenAPI schema: <http://localhost:8000/openapi.json>

A successful health check returns a response similar to:

```json
{
  "status": "ok",
  "database": "connected"
}
```

## Useful Commands

Stop the development server with `Ctrl+C`. To leave the virtual environment:

```powershell
deactivate
```

Create a new migration after changing the database models:

```powershell
python -m alembic revision --autogenerate -m "describe the change"
python -m alembic upgrade head
```

## Troubleshooting

### Database connection errors

- Confirm MySQL is running.
- Confirm the database exists.
- Check the `DATABASE_URL` value in `.env`.
- Confirm the MySQL user has access to the selected database.

### Port 8000 is already in use

Run the server on another port:

```powershell
python -m uvicorn app.main:app --reload --port 8001
```

Then open <http://localhost:8001/docs>.
