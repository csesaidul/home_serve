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
git clone https://github.com/csesaidul/home_serve.git
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

- `main` — stable, demo-ready branch. **Never commit directly to `main`.**
- Feature branches off `main`, named `feature/<short-description>` (e.g. `feature/booking-flow`).
- Open a pull request for review before merging, even for small changes.
- Keep backend and frontend changes in separate commits/PRs where possible to keep history reviewable.

## Git Workflow Guide (for teammates new to GitHub)

**First-time setup (do this once):**

```bash
git clone https://github.com/csesaidul/home_serve.git
cd home_serve
git config user.name "Your Name"
git config user.email "your_email@example.com"
```

**Before you start any new work — always sync with `main` first:**

```bash
git checkout main
git pull origin main
```

**Create your own branch for the task you're working on:**

```bash
git checkout -b feature/short-description
```
Example: `git checkout -b feature/login-screen`

**While working — save your progress regularly:**

```bash
git add .
git commit -m "Short, clear description of what you changed"
```

**Push your branch to GitHub:**

```bash
git push -u origin feature/short-description
```
(After the first push, `git push` alone is enough for that branch.)

**Open a Pull Request (PR):**
1. Go to the repo on GitHub — it will show a banner for your recently pushed branch.
2. Click **Compare & pull request**.
3. Write a short description of what you did, then **Create pull request**.
4. Ask at least one teammate to review before merging into `main`.

**After your PR is merged**, switch back to `main` and pull the latest changes before starting new work:
```bash
git checkout main
git pull origin main
```

### Rules to avoid conflicts and breakage

- **Never push directly to `main`.** All changes go through a feature branch + PR.
- **Pull before you push.** Always run `git pull origin main` before starting new work, to avoid painful merge conflicts.
- **One feature/fix per branch.** Don't mix unrelated changes in one branch or PR.
- **Commit often, with clear messages.** Small, frequent commits are easier to review and revert than one giant commit.
- **Never commit `.env` files**, API keys, passwords, or database credentials. Use `.env.example` to show what variables are needed, and keep real values only in your local `.env` (already excluded by `.gitignore`).
- **Don't commit generated/build folders** (`build/`, `.dart_tool/`, `venv/`, `__pycache__/`) — these are machine-specific and already excluded by `.gitignore`.
- **If you're unsure or stuck, ask before force-pushing or deleting branches** — `git push --force` and branch deletion can erase teammates' work.
- **Resolve merge conflicts carefully**: if Git reports a conflict, open the conflicting file, look for `<<<<<<<`, `=======`, `>>>>>>>` markers, manually choose the correct code, remove the markers, then `git add` the file and commit.

### "I broke my code and can't fix it" — going back to your last working commit

This happens to everyone. If your code is in a bad state with errors you can't solve, you don't need to panic or rewrite everything — Git already saved your working version in your last commit. Pick the situation that matches you:

**Case A: You haven't committed yet, and just want to undo all uncommitted changes (discard everything since your last commit)**
```bash
git restore .
```
This throws away all uncommitted edits in every file and brings everything back to your last commit. Use this when you've messed up files but never ran `git commit`.

**Case B: You want to undo changes in just one file**
```bash
git restore path/to/file.dart
```

**Case C: You already committed the broken code, but haven't pushed it yet, and want to fully undo the last commit (delete the commit and the changes)**
```bash
git reset --hard HEAD~1
```
`HEAD~1` means "1 commit before now." This deletes your last commit and all its changes completely. Use `HEAD~2` to go back 2 commits, and so on. ⚠️ This is destructive — the deleted changes are gone for good, so only use it if you're sure you don't need that code.

**Case D: You already committed the broken code AND pushed it to GitHub**

Don't use `git reset --hard` here, since it can cause conflicts for teammates who already pulled your broken commit. Instead, create a new commit that undoes the changes safely:
```bash
git revert HEAD
git push
```
This creates a new commit that reverses your last commit, while keeping full history intact for everyone.

**Case E: You just want to look at an old version without losing your current (broken) work**
```bash
git stash                 # temporarily saves your current changes aside
git log --oneline         # find the commit hash you want, e.g. a1b2c3d
git checkout a1b2c3d -- .  # restore all files to that commit's state
```
Run `git stash pop` later if you want your original (broken) changes back.

**Golden rule:** commit often, in small chunks, with working code at each step. The smaller your commits, the less you lose if you ever need to step back.

## Do's and Don'ts

✅ **Do**
- Pull from `main` before starting new work (`git pull origin main`).
- Work on a separate branch for every feature or fix.
- Commit small, working chunks of code frequently with clear messages.
- Test your code locally before pushing.
- Open a Pull Request and get at least one review before merging to `main`.
- Ask in the team chat if you're unsure about a Git command before running it — most mistakes are easy to undo *before* they're pushed, much harder after.
- Keep `.env.example` updated whenever you add a new environment variable, so teammates know what to set in their own `.env`.

❌ **Don't**
- Don't push directly to `main`. Ever — even for "just one small fix."
- Don't commit `.env` files, passwords, API keys, or database credentials.
- Don't commit generated/build folders (`build/`, `.dart_tool/`, `venv/`, `__pycache__/`, `node_modules/`) — they're already excluded by `.gitignore`, so if Git tries to track them, something's misconfigured — ask before forcing it in.
- Don't run `git push --force` unless you fully understand why — it can permanently overwrite and erase a teammate's pushed work.
- Don't delete someone else's branch without checking with them first.
- Don't commit large binary files (videos, large images, datasets) directly into the repo — use a shared drive link in `docs/` instead and reference it.
- Don't merge your own Pull Request without a teammate's review, even if it "looks fine."
- Don't edit another teammate's open branch directly — push your own commits to it only if they've asked you to collaborate on it.




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
