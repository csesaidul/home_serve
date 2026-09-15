# HomeServe MVP — Task Checklist: Saidul Islam (Lead Developer)

**Plan & task breakdown by:** [Saidul Islam](https://github.com/csesaidul)

**Sprint:** September 15–19, 2026

**Role:** Project Lead / Lead Developer (Flutter, GoRouter, Riverpod, integration, backup)

> ⚠️ **Rule:** If a task is not completed by its deadline, the **Team Lead (Saidul Islam)** will complete it — and the credit for that task will then go to the **Team Lead**.

---

## Day 1 — Tuesday, September 15

- [ ] **D1-T5 — Flutter project skeleton**
  - **Deadline:** 8:00 PM
  - **Depends on:** None
  - **Details:**
    - Start the project with `flutter create homeserve_app`
    - Set up a feature-wise folder structure: `lib/features/auth`, `lib/features/booking`, `lib/features/provider`, `lib/features/admin`, and `lib/core` (network client, secure storage wrapper, theme, constants)
    - Add packages to `pubspec.yaml`: `go_router`, `flutter_riverpod`, `flutter_secure_storage`
    - Set up route stubs with GoRouter (a placeholder page for each screen, e.g. `/login`, `/register`, `/home`, `/booking`, `/admin`)
    - Prepare the Riverpod provider folder structure (auth_provider.dart, booking_provider.dart, etc. — can stay empty/stub for now)

- [ ] **D1-T6 — API contract document (Postman)**
  - **Deadline:** 8:00 PM
  - **Depends on:** None
  - **Details:**
    - Build a Postman Collection covering all endpoints planned for the MVP (auth, provider, booking, review, payment, admin), based on requirement.md
    - For each endpoint include: method, URL path, sample request body, sample response — so Rabbi knows exactly what to build
    - Export the collection JSON to the repo's `/docs/postman_collection.json` and share it with Rabbi

---

## Day 2 — Wednesday, September 16

- [ ] **D2-T4 — Flutter Auth screens**
  - **Deadline:** 9:00 PM
  - **Depends on:** D2-T1 (Rabbi's Auth API), D1-T5
  - **Details:**
    - Register screen (name, gender, phone, password fields + validation)
    - Login screen (phone + password)
    - OTP Verify screen (mock OTP input)
    - Call Rabbi's `/auth/register`, `/auth/login`, `/auth/verify-otp` APIs and store auth data in Riverpod state
    - Store the JWT token in `flutter_secure_storage`

- [ ] **D2-T5 — GoRouter capability-based route guard**
  - **Deadline:** 9:00 PM
  - **Depends on:** D2-T1
  - **Details:**
    - Write redirect logic based on the `client_verified` / `provider_verified` / `is_admin` claims in the JWT
    - Redirect to `/login` when accessing a protected route without being logged in
    - Separately guard provider-only and admin-only routes

---

## Day 3 — Thursday, September 17

- [ ] **D3-T5 — Provider profile + category browse UI**
  - **Deadline:** 9:00 PM
  - **Depends on:** D3-T1 (Rabbi's Provider/Category API)
  - **Details:**
    - Category list/grid screen (load data from `GET /categories`, use Sajib's icons)
    - Provider profile view screen (bio, skills, categories, portfolio photos, rating display)

- [ ] **D3-T6 — Booking flow UI**
  - **Deadline:** 9:00 PM
  - **Depends on:** D3-T2 (Rabbi's Booking API)
  - **Details:**
    - Booking creation form (date, time, address input, show the selected provider)
    - Booking status screen (show current status: requested → accepted → completed)

---

## Day 4 — Friday, September 18

- [ ] **D4-T4 — Review & payment UI**
  - **Deadline:** 9:00 PM
  - **Depends on:** D4-T1 (Rabbi's Review/Payment API)
  - **Details:**
    - Review submission form (rating + comment), shown only when booking status = completed
    - Payment confirmation screen (simulated — "Pay Now" button calls the API to update payment_status)

- [ ] **D4-T5 — Admin panel UI**
  - **Deadline:** 9:00 PM
  - **Depends on:** D4-T2 (Rabbi's Admin API), D3-T4 (Sajib's hi-fi design)
  - **Details:**
    - Pending provider list + Approve/Reject buttons
    - Category CRUD screen (add/edit/delete category)

- [ ] **D4-T6 — Status polling integration**
  - **Deadline:** 9:00 PM
  - **Depends on:** D3-T6
  - **Details:**
    - Set up a Timer/StreamProvider in Riverpod to call `GET /booking/{id}/location` (or status) every 5 seconds (per FR-RT-03)
    - App should retry gracefully instead of crashing if the API call fails

---

## Day 5 — Saturday, September 19

- [ ] **D5-T1 — End-to-end integration testing** *(whole team together)*
  - **Deadline:** 2:00 PM
  - **Depends on:** All Day 1–4 tasks
  - **Details:** Test the full flow together, from registration through to payment/review; note down every bug found

- [ ] **D5-T3 — Flutter web build + deploy, Android APK build**
  - **Deadline:** 6:00 PM
  - **Depends on:** D5-T1
  - **Details:**
    - `flutter build web --release` and deploy the web build to a free host (Firebase Hosting / Netlify)
    - `flutter build apk --release` to produce the APK, save it under `/release`

- [ ] **D5-T5 — Final review, merge, release tag**
  - **Deadline:** 8:00 PM
  - **Depends on:** D5-T2 (Rabbi), D5-T3, D5-T4 (Sajib)
  - **Details:**
    - Review everyone's pending Pull Requests and merge into `main`
    - Publish the release tagged `v0.1-MVP`, listing who did which task in the release notes as credit

---

## Git Workflow — How to Submit Work

**Branch naming format:** `saidul/<task-id>-<short-name>`
Example: `saidul/D1-T5-flutter-skeleton`, `saidul/D2-T4-auth-screens`

```bash
# 1. Clone the repo (first time only)
 git clone https://github.com/csesaidul/home_serve.git
 cd home_serve

# 3. Update local main before starting new work
git checkout main
git pull origin main

# 2. Create a new branch off main (task ID + name)
git checkout -b saidul/D1-T5-flutter-skeleton

# 4. Do the work, then commit
git add .
git commit -m "D1-T5: Flutter project skeleton (GoRouter + Riverpod structure)"

# 5. Push the branch and open a Pull Request
git push origin saidul/D1-T5-flutter-skeleton
# On GitHub, open a PR from this branch into main
# Include the task ID (e.g. D1-T5) in the PR title/description

# 6. For the next task, repeat from step 1 (update) — new branch, new work
```

- Every task needs its **own branch** and its **own PR** — never mix multiple tasks into one PR.
- After a PR is sent, the **Team Lead (Saidul)** will review the code and merge it into `main`.
- The task is not considered "done" until it's merged.
