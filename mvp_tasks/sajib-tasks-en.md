# HomeServe MVP — Task Checklist: Sajib (Architecture Designer)

**Plan & task breakdown by:** [Saidul Islam](https://github.com/csesaidul)

**Sprint:** September 15–19, 2026

**Role:** Architecture Designer (Figma UI, DB Schema, API Contract support)

> ⚠️ **Rule:** If a task is not completed by its deadline, the **Team Lead (Saidul Islam)** will complete it — and the credit for that task will then go to the **Team Lead**. Delayed designs/schema block both Rabbi and Saidul's work, so on-time delivery matters.

---

## Day 1 — Tuesday, September 15

- [ ] **D1-T1 — Finalize the ER diagram**
  - **Deadline:** 8:00 PM
  - **Depends on:** None
  - **Details:**
    - Cover the simplified schema: `users`, `client_profiles`, `provider_profiles`, `service_categories`, `bookings`, `reviews`
    - Clearly show each table's fields and primary key/foreign key relationships (see the "Key Entities" section of requirement.md)
    - Use draw.io or dbdiagram.io to build the diagram
    - Save it as an image/link in the repo's `/docs/er-diagram.png` and share it with Rabbi (his D1-T4 depends on it)

- [ ] **D1-T2 — Low-fi Figma wireframes**
  - **Deadline:** 8:00 PM
  - **Depends on:** None
  - **Details:**
    - Screen list: Splash, Register, Login, OTP Verify, Home/Category Browse, Provider Profile View, Booking Creation, Booking Status, Admin Login, Admin Dashboard
    - Fix consistent spacing, typography, and a basic color palette (the whole team will follow this style)
    - Share the Figma file's shareable link with the team

---

## Day 2 — Wednesday, September 16

- [ ] **D2-T2 — Finalize Figma booking/review screens**
  - **Deadline:** 6:00 PM
  - **Depends on:** D1-T2
  - **Details:**
    - Booking status timeline screen (show requested → accepted → completed)
    - Review submission screen, payment confirmation screen
    - Export all icons/assets as PNG/SVG into the repo's `/docs/design`

- [ ] **D2-T3 — Prepare category seed data**
  - **Deadline:** 8:00 PM
  - **Depends on:** None
  - **Details:**
    - `service_categories.json` — at least 5–6 categories (e.g. Electrician, Plumber, AC Repair, Cleaning, Tutor, Carpenter), each with name, icon name, base_price
    - Prepare an icon for each category (a free icon set is fine), save into `/assets/icons`

---

## Day 3 — Thursday, September 17

- [ ] **D3-T3 — QA on Day 1–2 delivered screens**
  - **Deadline:** 6:00 PM
  - **Depends on:** D2-T4 (Saidul's Auth screens)
  - **Details:**
    - Compare the implemented Auth screens against the Figma design (spacing, color, missing fields)
    - Log every mismatch/bug found as a checklist in `/docs/qa-day3.md`

- [ ] **D3-T4 — Admin panel hi-fi wireframe**
  - **Deadline:** 8:00 PM
  - **Depends on:** D1-T2
  - **Details:**
    - Provider approval list screen (pending providers + approve/reject buttons)
    - Category CRUD screen — this time with hi-fi detail (Saidul's D4-T5 will follow this design)

---

## Day 4 — Friday, September 18

- [ ] **D4-T3 — QA support + deployment diagram**
  - **Deadline:** 6:00 PM
  - **Depends on:** D3-T3
  - **Details:**
    - Help Rabbi and Saidul fix schema/field issues found during QA (communicate and clarify as needed)
    - Draw a simple deployment diagram: Flutter Web hosting → Backend server → MySQL — showing how everything connects
    - Save it to `/docs/deployment.png`

---

## Day 5 — Saturday, September 19

- [ ] **D5-T1 — End-to-end integration testing** *(whole team together)*
  - **Deadline:** 2:00 PM
  - **Depends on:** All Day 1–4 tasks
  - **Details:** Do a final check comparing the implementation against the UI design, note down any visual bugs

- [ ] **D5-T4 — Final QA, demo script, README, screenshots**
  - **Deadline:** 6:00 PM
  - **Depends on:** D5-T1
  - **Details:**
    - Hands-on test of the full app (mobile + web), build a final bug list
    - Write a demo script — step-by-step what to click during the demo
    - Take screenshots of every major screen and add them to `README.md`

---

## Git Workflow — How to Submit Work

**Branch naming format:** `sajib/<task-id>-<short-name>`
Example: `sajib/D1-T1-er-diagram`, `sajib/D2-T2-figma-booking-screens`

> Note: Design files (Figma) may not go directly into the repo, but diagrams/seed data/documentation/exported assets (PNG, JSON) that do go into the repo should follow the same workflow below.

```bash
# 1. Clone the repo (first time only)
git clone <REPO-URL>
cd homeserve

# 3. Update local main before starting new work
git checkout main
git pull origin main

# 2. Create a new branch off main (task ID + name)
git checkout -b sajib/D1-T1-er-diagram

# 4. Do the work, then commit
git add .
git commit -m "D1-T1: ER diagram for MVP schema (users, bookings, providers etc.)"

# 5. Push the branch and open a Pull Request
git push origin sajib/D1-T1-er-diagram
# On GitHub, open a PR from this branch into main
# Include the task ID (e.g. D1-T1) in the PR title/description

# 6. For the next task, repeat from step 1 (update) — new branch, new work
```

- Every task needs its **own branch** and its **own PR** — never mix multiple tasks into one PR.
- After a PR is sent, the **Team Lead (Saidul)** will review it and merge it into `main`.
- The task is not considered "done" until it's merged.
