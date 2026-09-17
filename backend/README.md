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
