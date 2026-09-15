# HomeServe — 5-Day MVP Sprint Plan (Release 1: Mobile + Web)

**Plan by:** [Saidul Islam](https://github.com/csesaidul)

**Created:** September 15, 2026 | **Deadline:** September 19, 2026 (Saturday), 8:00 PM

**Team:**
- **Saidul Islam** — Project Lead & Lead Developer (Flutter, GoRouter, Riverpod, coordination, backup)
- **Rabbi** — Backend Developer (FastAPI + XAMPP/MySQL)
- **Sajib** — Architecture Designer (Figma UI, DB schema, API contract)

---

## 0. Why the Scope Was Trimmed

The original requirement.md includes real OTP via AWS SNS, 2FA, device fingerprinting + lockout + blacklisting, rule-based fraud scoring, and full WebSocket chat/live location. Delivering all of that with a 3-person team in 5 days isn't realistic. So MVP Release 1 keeps only the **core value loop**, so the app works end-to-end and can actually be demoed. The architecture is kept extensible so the remaining features can be added later (consistent with the scalability requirement in NFR 2.5).

### What's In MVP Release 1
| Req ID | Feature | Note |
|---|---|---|
| FR-01, FR-04 | Registration (phone+name+gender+password) & password login | |
| FR-02 (simplified) | OTP verification | **Mock OTP** (fixed code, shown in logs) instead of AWS SNS — to save time |
| FR-08, FR-09 (simplified) | Capability-based JWT (client/provider/is_admin flags) | Dynamic claim structure kept, but 2FA/fraud claims dropped |
| FR-10 | Token storage via Flutter Secure Storage | |
| FR-15, FR-17, FR-A-01 | Provider profile submission + admin approval | |
| FR-C-01, FR-C-02 | Category/provider browse & profile view | |
| FR-C-03, FR-C-04 | Booking creation + status (requested→accepted→completed) | No WebSocket — **5-second polling** (allowed fallback per FR-RT-03) |
| FR-C-06 | Price estimate + simulated payment | |
| FR-C-07, FR-P-08 (simplified) | Rating/review | |
| FR-A-02 | Admin category management | |
| 3.1 | Same Flutter codebase built/deployed to Android + Web | |

### Deferred to the Next Sprint (Not in MVP-1)
2FA (FR-13), real AWS SNS OTP, device fingerprinting/lockout/blacklisting (FR-18–23), fraud scoring (FR-24), in-app chat (FR-C-05/FR-P-06), live GPS streaming (real-time part of FR-P-05), earnings dashboard (FR-P-07), dispute resolution (FR-A-05), rebooking (FR-C-08), availability calendar (FR-P-03).

---

## Rule: Dependencies & Missed Deadlines

- Every day has an **8:00 PM check-in point** to confirm that day's tasks are done.
- Every task lists which earlier task it depends on. If the earlier task is blocked, the next one can't start either — so a missed deadline immediately becomes a blocker.
- **If anyone fails to finish their task by its deadline, Saidul (Lead Developer) will take it over and finish it quickly so the next day's work isn't blocked — and will receive credit for that task (in the README/commit).**
- For this reason, Saidul's own task load is deliberately kept a bit lighter (buffer), to leave room for takeovers.

---

## Day 1 — Tuesday, September 15 — Foundation

| Task | Owner | Deadline | Depends On |
|---|---|---|---|
| D1-T1: Finalize ER diagram (simplified: users, client_profiles, provider_profiles, service_categories, bookings, reviews) | Sajib | 8:00 PM | — |
| D1-T2: Low-fi Figma wireframes — auth, home/browse, booking flow, provider profile, admin panel | Sajib | 8:00 PM | — |
| D1-T3: XAMPP + MySQL local setup, FastAPI project skeleton (module-based folders: auth, booking, admin) | Rabbi | 8:00 PM | — |
| D1-T4: DB migration scripts (can start from D1-T1's draft schema) | Rabbi | 8:00 PM | D1-T1 (draft) |
| D1-T5: Flutter project skeleton — GoRouter route stubs, Riverpod provider structure, feature-wise folders | Saidul | 8:00 PM | — |
| D1-T6: API contract doc (Postman collection skeleton) per requirement.md, shared with Rabbi | Saidul | 8:00 PM | — |

## Day 2 — Wednesday, September 16 — Auth End-to-End

| Task | Owner | Deadline | Depends On |
|---|---|---|---|
| D2-T1: Auth API — register, password login, mock-OTP verify, JWT issuance (capability claims) | Rabbi | 8:00 PM | D1-T3, D1-T4 |
| D2-T2: Finalize Figma — booking status & review screens; export icons/assets | Sajib | 6:00 PM | D1-T2 |
| D2-T3: service_categories seed data (JSON) + category icons ready | Sajib | 8:00 PM | — |
| D2-T4: Flutter auth screens (register/login/OTP mock) wired to Riverpod | Saidul | 9:00 PM | D2-T1, D1-T5 |
| D2-T5: GoRouter capability-based route guarding (client/provider/admin) | Saidul | 9:00 PM | D2-T1 |

## Day 3 — Thursday, September 17 — Core Booking Flow

| Task | Owner | Deadline | Depends On |
|---|---|---|---|
| D3-T1: Provider profile + category API (CRUD + admin approval endpoint) | Rabbi | 8:00 PM | D2-T1 |
| D3-T2: Booking API (create, list, status transition, price estimate) | Rabbi | 8:00 PM | D2-T1 |
| D3-T3: QA Day 1–2 delivered screens against Figma + bug list | Sajib | 6:00 PM | D2-T4 |
| D3-T4: Admin panel hi-fi wireframe + approval flow | Sajib | 8:00 PM | D1-T2 |
| D3-T5: Provider profile + category browse UI (client side) | Saidul | 9:00 PM | D3-T1 |
| D3-T6: Booking flow UI (create booking, view status) | Saidul | 9:00 PM | D3-T2 |

## Day 4 — Friday, September 18 — Review, Payment, Admin

| Task | Owner | Deadline | Depends On |
|---|---|---|---|
| D4-T1: Review/rating API + simulated payment endpoint | Rabbi | 8:00 PM | D3-T2 |
| D4-T2: Admin API — provider approval, category management, basic stats | Rabbi | 8:00 PM | D3-T1 |
| D4-T3: Support Rabbi/Saidul on schema fixes found in QA; finalize web deployment diagram | Sajib | 6:00 PM | D3-T3 |
| D4-T4: Review/rating UI + payment confirmation UI | Saidul | 9:00 PM | D4-T1 |
| D4-T5: Admin panel UI (provider approval, category CRUD) | Saidul | 9:00 PM | D4-T2, D3-T4 |
| D4-T6: Status polling integration (5-second GET /booking/{id}/location, FR-RT-03) | Saidul | 9:00 PM | D3-T6 |

## Day 5 — Saturday, September 19 — Integration & Release

| Task | Owner | Deadline | Depends On |
|---|---|---|---|
| D5-T1: End-to-end integration testing (whole team, cross-check every flow) | Everyone | 2:00 PM | All Day 1–4 tasks |
| D5-T2: Backend deployment prep (production config, env vars) | Rabbi | 4:00 PM | D5-T1 |
| D5-T3: Flutter web build + deploy, and Android APK build | Saidul | 6:00 PM | D5-T1 |
| D5-T4: Final QA, demo script/README, screenshot documentation | Sajib | 6:00 PM | D5-T1 |
| D5-T5: Final review, merge, release tag `v0.1-MVP` | Saidul | 8:00 PM | D5-T2, D5-T3, D5-T4 |

---

## Quick Reference — Who Owns What

- **Rabbi (Backend):** DB setup → auth API → provider/category/booking API → review/payment/admin API → deploy prep (an API delivery every day, which Saidul's UI work depends on)
- **Sajib (Architecture):** ER diagram + wireframes (Day 1) → final screens + seed data (Day 2) → QA + admin wireframe (Day 3) → support + deployment diagram (Day 4) → final QA + README (Day 5)
- **Saidul (Lead):** Flutter/GoRouter/Riverpod skeleton → integrates each UI as soon as the matching API is ready → web/mobile build + release, and backup for any missed task
