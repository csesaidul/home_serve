# HomeServe

A two-sided marketplace platform that connects verified home-service providers (plumbers, electricians, cleaners, and similar tradespeople) with customers who need on-demand help around the house. HomeServe ships as an Android & Web client built with Flutter, backed by a FastAPI service and a MySQL database.

This repository is a monorepo containing the backend, frontend, and project documentation.

## Repository Structure

```
homeserve/
├── backend/          # FastAPI service (REST + WebSocket API, MySQL via XAMPP)
├── frontend/         # Flutter app (Android & Web) — Riverpod + GoRouter
├── docs/             # Project plans, proposal report, diagrams, meeting notes
└── README.md         # You are here
```

| Module | Description | Stack |
|---|---|---|
| [`backend/`](./backend) | REST + WebSocket API, authentication, business logic | FastAPI (Python), MySQL, JWT |
| [`frontend/`](./frontend) | Customer, Provider, and Admin client app | Flutter, Riverpod, GoRouter, Secure Storage |
| [`docs/`](./docs) | Proposal report, system design, sprint plans, ER diagrams | Markdown / docx / images |

## Tech Stack

- **Frontend:** Flutter (Android & Web), Riverpod for state management, GoRouter for navigation, Flutter Secure Storage for encrypted token storage.
- **Backend:** FastAPI (Python), async REST endpoints, WebSocket endpoints for real-time chat and live location.
- **Database:** MySQL, managed locally via XAMPP/phpMyAdmin during development.
- **Auth:** JWT-based authentication with role-based access control (Customer / Provider / Admin).

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev) (stable channel)
- Python 3.11+
- [XAMPP](https://www.apachefriends.org) (MySQL + phpMyAdmin)
- Git

### 1. Clone the repository

```bash
git clone <repo-url>
cd homeserve
```

### 2. Backend setup

```bash
cd backend
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env            # set DB credentials, JWT secret, etc.
uvicorn app.main:app --reload   # API at http://localhost:8000
```

See [`backend/README.md`](./backend/README.md) for database setup, migrations, and API docs (Swagger at `/docs` once running).

### 3. Database setup

1. Start MySQL and Apache from the XAMPP control panel.
2. Open phpMyAdmin and create a database (e.g. `homeserve_db`).
3. Run the schema/seed scripts in `backend/db/` (see `backend/README.md`).

### 4. Frontend setup

```bash
cd frontend
flutter pub get
flutter run -d chrome           # run on Web
flutter run                     # run on a connected Android device/emulator
```

Update the API base URL in `frontend/lib/config/` to point at your local backend (default `http://localhost:8000`).

See [`frontend/README.md`](./frontend/README.md) for folder structure, state management conventions, and environment configuration.

## Documentation

The [`docs/`](./docs) folder holds everything that isn't code:

- Project proposal report
- Problem statement, scope, and objectives
- System architecture and database design (ER diagram)
- Sprint plan / project timeline
- Risk management and testing & evaluation plan
- Meeting notes and decision log

Start with [`docs/proposal-report.md`](./docs/proposal-report.md) (or the `.docx` version) for the full project overview.

## Branching & Workflow

- `main` — stable, demo-ready branch.
- Feature branches off `main`, named `feature/<short-description>` (e.g. `feature/booking-flow`).
- Open a pull request for review before merging, even for small changes.
- Keep backend and frontend changes in separate commits/PRs where possible to keep history reviewable.

## Team

| Member | Role |
|---|---|
| Member 1 | Lead Developer — Flutter architecture, FastAPI backend, auth & WebSocket logic, integration |
| Member 2 | UI/UX & Frontend Support — Figma wireframes, static screens, manual testing |
| Member 3 | Documentation & Database — MySQL schema, seed data, proposal/report writing |

## Project Status

🚧 In development — course project, target timeline: 8 weeks. See [`docs/`](./docs) for the current sprint plan and scope boundaries (MVP).

## License

This project is developed for academic purposes as part of a Software Development course.