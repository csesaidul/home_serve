# Git Branch Management & Safe Merge Workflow

> VS Code Terminal থেকে Git Repository-এর Branch দেখা, Checkout করা, Branch যাচাই করা এবং নিরাপদে `main` Branch-এর সাথে Merge করার সম্পূর্ণ গাইড।

---

# 1. Git Branch কী?

Git-এ **branch** হলো একই project-এর codebase-এর একটি আলাদা development line।

উদাহরণ:

```text
main
├── feature/short-description
└── sajib/requirement
```

সাধারণত:

* `main` → মূল/production-ready code
* `feature/...` → নতুন feature development
* `sajib/...` → কোনো developer বা নির্দিষ্ট task-এর branch

একটি Git repository-তে branch দুই ধরনের হতে পারে:

1. **Local Branch** — আপনার কম্পিউটারে থাকা branch
2. **Remote Branch** — GitHub/GitLab-এর মতো remote repository-তে থাকা branch

---

# 2. Remote Repository থেকে সর্বশেষ Branch Information আনা

Remote repository-তে নতুন branch তৈরি হলে আপনার local Git সঙ্গে সঙ্গে সেটি জানতে পারে না।

সর্বশেষ branch information আনতে:

```bash
git fetch --all
```

অথবা:

```bash
git fetch origin
```

`git fetch` আপনার বর্তমান code পরিবর্তন করে না। এটি শুধু remote repository-এর সর্বশেষ information local Git-এ update করে।

---

# 3. সব Local এবং Remote Branch দেখা

সব branch দেখতে:

```bash
git branch -a
```

উদাহরণ:

```text
  feature/short-description
* main
  remotes/origin/HEAD -> origin/main
  remotes/origin/feature/short-description
  remotes/origin/main
  remotes/origin/sajib/requirement
```

এখানে:

```text
feature/short-description
```

একটি local branch।

```text
* main
```

`*` চিহ্ন দ্বারা বোঝানো হচ্ছে বর্তমানে আপনি `main` branch-এ আছেন।

```text
remotes/origin/sajib/requirement
```

এটি একটি remote branch।

Remote branch-এর প্রকৃত নাম:

```text
origin/sajib/requirement
```

---

# 4. শুধু Local Branch দেখা

```bash
git branch
```

উদাহরণ:

```text
  feature/short-description
* main
```

---

# 5. শুধু Remote Branch দেখা

```bash
git branch -r
```

উদাহরণ:

```text
origin/HEAD -> origin/main
origin/feature/short-description
origin/main
origin/sajib/requirement
```

---

# 6. বর্তমান Branch জানা

বর্তমানে কোন branch-এ আছেন:

```bash
git branch --show-current
```

অথবা:

```bash
git status
```

---

# 7. Local Branch-এ Switch করা

যদি branch local-এ থাকে:

```bash
git switch branch-name
```

উদাহরণ:

```bash
git switch feature/short-description
```

পুরোনো syntax:

```bash
git checkout feature/short-description
```

বর্তমান Git-এ branch পরিবর্তনের জন্য `git switch` ব্যবহার করা বেশি পরিষ্কার।

---

# 8. Remote Branch-এ প্রথমবার Switch করা

ধরা যাক branch list-এ আছে:

```text
remotes/origin/sajib/requirement
```

এটি একটি remote branch।

সরাসরি:

```bash
git switch remotes/origin/sajib/requirement
```

ব্যবহার করলে error হতে পারে:

```text
fatal: a branch is expected, got remote branch 'origin/sajib/requirement'
```

কারণ এটি local branch নয়।

Remote branch থেকে local tracking branch তৈরি করতে:

```bash
git switch --track origin/sajib/requirement
```

এতে:

```text
Remote Branch
origin/sajib/requirement
        │
        │ --track
        ▼
Local Branch
sajib/requirement
```

তৈরি হবে।

পরবর্তীতে এই branch-এ যেতে:

```bash
git switch sajib/requirement
```

---

# 9. Branch-এর Remote Tracking Information দেখা

Local branch কোন remote branch track করছে তা দেখতে:

```bash
git branch -vv
```

উদাহরণ:

```text
* sajib/requirement
  123abcd [origin/sajib/requirement] Latest commit
```

এখানে:

```text
Local Branch:
sajib/requirement

Tracks:
origin/sajib/requirement
```

---

# 10. Branch Merge করার আগে গুরুত্বপূর্ণ ধারণা

ধরা যাক আপনার repository-তে:

```text
main
│
├── feature/short-description
│
└── sajib/requirement
```

আপনি `sajib/requirement` branch-এ কাজ করেছেন।

এখন আপনার লক্ষ্য:

```text
sajib/requirement
        │
        │  Check & Test
        ▼
    Everything OK?
        │
       Yes
        │
        ▼
      main
```

কিন্তু সরাসরি merge করার আগে কয়েকটি বিষয় যাচাই করা উচিত।

---

# 11. Safe Merge Workflow

একটি branch `main`-এর সাথে merge করার আগে এই workflow অনুসরণ করুন:

```text
1. Branch নির্বাচন
       ↓
2. Working Tree পরিষ্কার?
       ↓
3. সর্বশেষ Remote Changes Fetch
       ↓
4. Feature Branch Update
       ↓
5. Main-এর সর্বশেষ Changes Feature Branch-এ আনা
       ↓
6. Merge Conflict Check
       ↓
7. Dependency Check
       ↓
8. Build Check
       ↓
9. Test Run
       ↓
10. Lint / Static Analysis
       ↓
11. Application Manual Test
       ↓
12. Main-এর সাথে Compatibility Check
       ↓
13. সব ঠিক আছে?
       ↓
   Yes ─────────────── No
    ↓                  ↓
 Main-এ Merge       Fix করুন
    ↓                  │
 Post-Merge Test  ←────┘
    ↓
 Push to Remote
```

---

# 12. Step 1 — সঠিক Branch নির্বাচন করুন

প্রথমে সব branch দেখুন:

```bash
git branch -a
```

তারপর যে branch পরীক্ষা করবেন সেটিতে যান:

```bash
git switch sajib/requirement
```

যাচাই করুন:

```bash
git branch --show-current
```

Output:

```text
sajib/requirement
```

---

# 13. Step 2 — Working Tree পরিষ্কার কিনা দেখুন

Merge বা update করার আগে:

```bash
git status
```

যদি দেখায়:

```text
nothing to commit, working tree clean
```

তাহলে ভালো।

যদি uncommitted changes থাকে, আগে সেগুলো:

### Commit করুন

```bash
git add .
git commit -m "Complete requirement implementation"
```

অথবা সাময়িকভাবে stash করুন:

```bash
git stash
```

---

# 14. Step 3 — সর্বশেষ Remote Changes আনুন

প্রথমে:

```bash
git fetch --all
```

এতে remote-এর সর্বশেষ branch information পাওয়া যাবে।

---

# 15. Step 4 — Feature Branch সর্বশেষ অবস্থায় আছে কিনা নিশ্চিত করুন

আপনি যদি `sajib/requirement` branch-এ থাকেন:

```bash
git switch sajib/requirement
```

তারপর:

```bash
git pull
```

এতে remote branch-এর সর্বশেষ changes local branch-এ আসবে।

---

# 16. Step 5 — Main Branch-এর সর্বশেষ Changes Feature Branch-এ আনুন

এটি অত্যন্ত গুরুত্বপূর্ণ।

ধরা যাক:

```text
main
  │
  ├── A
  ├── B
  └── C

sajib/requirement
  │
  ├── A
  ├── B
  └── D
```

এখন `main`-এ নতুন পরিবর্তন এসেছে।

Merge করার আগে `main`-এর সর্বশেষ code আপনার feature branch-এ এনে পরীক্ষা করা ভালো।

প্রথমে remote update:

```bash
git fetch origin
```

তারপর feature branch-এ নিশ্চিত করুন:

```bash
git switch sajib/requirement
```

এখন `main` merge করুন:

```bash
git merge origin/main
```

অথবা local `main` branch আপডেট করা থাকলে:

```bash
git merge main
```

এখন যদি conflict হয়, সেটি feature branch-এই resolve করুন।

এটি নিরাপদ কারণ:

```text
main
  │
  │
  ▼
sajib/requirement
  │
  ├── Resolve Conflicts
  ├── Build
  ├── Test
  └── Verify
        │
        ▼
      main
```

অর্থাৎ `main`-এ merge করার আগে সম্ভাব্য integration problem ধরা যাবে।

---

# 17. Step 6 — Merge Conflict Check

যদি:

```bash
git merge origin/main
```

চালানোর পর conflict হয়, Git জানাবে।

Conflict দেখতে:

```bash
git status
```

যে file-গুলোতে conflict হয়েছে, সেগুলো VS Code-এ খুলুন।

সাধারণত এমন দেখা যায়:

```text
<<<<<<< HEAD

Your branch code

=======

Main branch code

>>>>>>> origin/main
```

VS Code-এর সাহায্যে নির্বাচন করতে পারেন:

* Accept Current Change
* Accept Incoming Change
* Accept Both Changes
* Compare Changes

Conflict resolve করার পর:

```bash
git add .
```

তারপর:

```bash
git commit
```

অথবা Git-এর নির্দেশনা অনুযায়ী merge commit সম্পন্ন করুন।

তারপর আবার test করুন।

---

# 18. Step 7 — Dependency Check

Project-এর dependency সঠিক আছে কিনা যাচাই করুন।

Flutter project হলে:

```bash
flutter pub get
```

তারপর:

```bash
flutter pub outdated
```

যদি dependency সমস্যা থাকে, আগে ঠিক করুন।

Node.js project হলে:

```bash
npm install
```

Python project হলে virtual environment সক্রিয় করে dependency install করুন।

উদাহরণ:

```bash
pip install -r requirements.txt
```

---

# 19. Step 8 — Build Check

Branch-এর code build হচ্ছে কিনা পরীক্ষা করুন।

Flutter project হলে:

```bash
flutter build apk --debug
```

অথবা:

```bash
flutter build windows --debug
```

Release build যাচাই করতে:

```bash
flutter build apk --release
```

Project-এর platform অনুযায়ী build command ব্যবহার করুন।

Build fail করলে merge করার আগে অবশ্যই error fix করুন।

---

# 20. Step 9 — Test Run করুন

Automated test থাকলে অবশ্যই চালান।

Flutter:

```bash
flutter test
```

Node.js:

```bash
npm test
```

Python:

```bash
pytest
```

লক্ষ্য:

```text
All Tests Passed
```

যদি test fail করে:

```text
Test Failed
    ↓
Find Cause
    ↓
Fix Code
    ↓
Run Test Again
```

সব test pass না করা পর্যন্ত merge না করাই ভালো।

---

# 21. Step 10 — Static Analysis এবং Lint Check

Flutter project হলে:

```bash
flutter analyze
```

Dart formatting check:

```bash
dart format --output=none --set-exit-if-changed .
```

যদি lint error থাকে, আগে fix করুন।

অন্যান্য language/project-এর ক্ষেত্রে project-specific lint tool ব্যবহার করুন।

---

# 22. Step 11 — Manual Testing

Automated test pass করলেও application manually test করা উচিত।

বিশেষ করে যেসব feature branch-এ পরিবর্তন করা হয়েছে সেগুলো পরীক্ষা করুন।

উদাহরণ:

```text
✓ App Launch
✓ Login
✓ Registration
✓ Navigation
✓ API Request
✓ Data Loading
✓ Create
✓ Update
✓ Delete
✓ Error Handling
✓ Loading State
✓ Empty State
✓ Offline/Error State
```

UI পরিবর্তন হলে:

```text
✓ Layout
✓ Responsive UI
✓ Button Action
✓ Text
✓ Font
✓ Spacing
✓ Overflow
```

---

# 23. Step 12 — Main Branch-এর সাথে Compatibility Check

এখন নিশ্চিত করুন:

```text
Feature Branch
      +
Latest Main
      =
Working Application
```

এ জন্য সবচেয়ে ভালো পদ্ধতি:

```bash
git fetch origin
git switch sajib/requirement
git merge origin/main
```

তারপর আবার:

```bash
flutter pub get
flutter analyze
flutter test
```

এবং প্রয়োজন অনুযায়ী:

```bash
flutter build apk --debug
```

তারপর application manually test করুন।

এখন যদি সব ঠিক থাকে, তাহলে ধরে নেওয়া যায় branch-টি `main`-এর সাথে integration-এর জন্য প্রস্তুত।

---

# 24. Step 13 — Merge করার আগে Final Checklist

Merge করার আগে এই checklist অনুসরণ করুন:

```text
[ ] সঠিক branch-এ আছি
[ ] Working tree clean
[ ] Remote changes fetch করা হয়েছে
[ ] Feature branch সর্বশেষ commit-এ আছে
[ ] Latest main branch feature branch-এ merge করা হয়েছে
[ ] Merge conflict নেই
[ ] Dependency ঠিক আছে
[ ] Build সফল
[ ] Automated tests pass
[ ] Lint / Analyze pass
[ ] Manual testing সম্পন্ন
[ ] API integration ঠিক আছে
[ ] Database-related functionality ঠিক আছে
[ ] UI/UX ঠিক আছে
[ ] No obvious bugs
[ ] Main-এর সাথে compatibility verified
```

সবগুলো ঠিক থাকলে merge করুন।

---

# 25. Main Branch-এ Merge করার পদ্ধতি

প্রথমে `main` branch-এ যান:

```bash
git switch main
```

Main branch-এর সর্বশেষ version আনুন:

```bash
git pull origin main
```

এখন feature branch merge করুন:

```bash
git merge sajib/requirement
```

যদি কোনো conflict না থাকে, merge সম্পন্ন হবে।

---

# 26. Merge-এর পর Main Branch Test করুন

Merge সফল হলেও কাজ শেষ নয়।

প্রথমে:

```bash
git status
```

তারপর project-এর dependency update করুন।

Flutter:

```bash
flutter pub get
```

তারপর:

```bash
flutter analyze
```

Test:

```bash
flutter test
```

Build:

```bash
flutter build apk --debug
```

তারপর application চালিয়ে manually test করুন।

অর্থাৎ:

```text
Feature Branch Test
        ↓
Merge to Main
        ↓
Main Branch Test Again
        ↓
Everything OK?
```

কারণ feature branch-এ ঠিক থাকলেও merge-এর পরে integration issue তৈরি হতে পারে।

---

# 27. Main Branch Remote-এ Push করা

সব test সফল হলে:

```bash
git push origin main
```

অথবা upstream configured থাকলে:

```bash
git push
```

---

# 28. সম্পূর্ণ Safe Merge Workflow

আপনার daily development-এর জন্য এই workflow ব্যবহার করতে পারেন:

```bash
# 1. Remote update
git fetch --all

# 2. Feature branch-এ যান
git switch sajib/requirement

# 3. Feature branch update করুন
git pull

# 4. Main-এর সর্বশেষ changes আনুন
git merge origin/main

# 5. Conflict থাকলে resolve করুন
git status

# 6. Dependency install/update
flutter pub get

# 7. Static analysis
flutter analyze

# 8. Automated tests
flutter test

# 9. Build check
flutter build apk --debug

# 10. Application manually test করুন
# Login, API, UI, Navigation ইত্যাদি

# 11. সব ঠিক থাকলে Main branch-এ যান
git switch main

# 12. Main update করুন
git pull origin main

# 13. Feature branch merge করুন
git merge sajib/requirement

# 14. Main branch আবার পরীক্ষা করুন
flutter pub get
flutter analyze
flutter test
flutter build apk --debug

# 15. সব ঠিক থাকলে remote-এ push করুন
git push origin main
```

---

# 29. আরও নিরাপদ Workflow — Merge করার আগে Backup Branch

যদি `main` খুব গুরুত্বপূর্ণ হয়, merge করার আগে একটি backup branch তৈরি করতে পারেন:

```bash
git switch main
git pull origin main
git switch -c backup/main-before-merge
```

এতে merge-এর আগের `main` অবস্থার একটি reference থাকবে।

তবে সাধারণত remote repository এবং Git history থাকায় আলাদা backup branch সবসময় প্রয়োজন হয় না।

---

# 30. Merge-এর আগে Commit History দেখা

Feature branch-এর commit history দেখতে:

```bash
git log --oneline --graph --decorate --all
```

এতে branch structure visually বোঝা যায়।

আরও সংক্ষিপ্তভাবে:

```bash
git log --oneline
```

---

# 31. Main থেকে Feature Branch কতটা এগিয়ে আছে দেখা

বর্তমান branch-এর সাথে `main`-এর commit difference দেখতে:

```bash
git log main..sajib/requirement --oneline
```

এতে `sajib/requirement`-এ আছে কিন্তু `main`-এ নেই এমন commit দেখা যাবে।

আর:

```bash
git log sajib/requirement..main --oneline
```

এতে `main`-এ আছে কিন্তু feature branch-এ নেই এমন commit দেখা যাবে।

---

# 32. Merge-এর আগে Changes Compare করা

Feature branch এবং main-এর code difference দেখতে:

```bash
git diff main...sajib/requirement
```

অথবা:

```bash
git diff origin/main...sajib/requirement
```

এতে merge করার আগে কী কী code পরিবর্তন হয়েছে তা দেখা যাবে।

---

# 33. Merge করার আগে Final Decision

Merge করার আগে নিজেকে এই প্রশ্নগুলো করুন:

### Code

```text
Code কি সম্পূর্ণ?
```

### Build

```text
Project কি successfully build হচ্ছে?
```

### Tests

```text
সব automated test কি pass করছে?
```

### Main Compatibility

```text
Latest main-এর সাথে কি কাজ করছে?
```

### Conflict

```text
কোনো unresolved merge conflict আছে কি?
```

### Manual Test

```text
বাস্তবে feature কি ঠিকভাবে কাজ করছে?
```

### Regression

```text
পুরোনো functionality কি ভেঙে গেছে?
```

সব উত্তর যদি:

```text
YES
```

হয়, তাহলে branch merge করার জন্য প্রস্তুত।

---

# 34. Recommended Branch Strategy

একটি ছোট বা medium-sized project-এর জন্য:

```text
main
│
├── feature/login
├── feature/payment
├── feature/profile
└── bugfix/api-error
```

Development flow:

```text
main
 │
 ├── Create Feature Branch
 │        │
 │        ▼
 │   Develop Feature
 │        │
 │        ▼
 │   Commit Changes
 │        │
 │        ▼
 │   Pull Latest Main
 │        │
 │        ▼
 │   Merge Main into Feature
 │        │
 │        ▼
 │   Resolve Conflicts
 │        │
 │        ▼
 │   Build + Test + Analyze
 │        │
 │        ▼
 │   Manual Testing
 │        │
 │        ▼
 │   Ready?
 │    /      \
 │  No        Yes
 │  │          │
 │ Fix         ▼
 │  │       Merge to Main
 │  │          │
 │  └──────────┤
 │             ▼
 │       Test Main Again
 │             │
 │             ▼
 │       Push Main
```

---

# 35. Quick Reference

| কাজ                                  | Command                                      |
| ------------------------------------ | -------------------------------------------- |
| সব branch দেখা                       | `git branch -a`                              |
| Local branch দেখা                    | `git branch`                                 |
| Remote branch দেখা                   | `git branch -r`                              |
| Current branch দেখা                  | `git branch --show-current`                  |
| Remote update                        | `git fetch --all`                            |
| Local branch switch                  | `git switch branch-name`                     |
| Remote branch checkout               | `git switch --track origin/branch-name`      |
| Branch tracking দেখা                 | `git branch -vv`                             |
| Remote branch update                 | `git pull`                                   |
| Main-এর changes feature branch-এ আনা | `git merge origin/main`                      |
| Merge conflict check                 | `git status`                                 |
| Code difference দেখা                 | `git diff main...branch-name`                |
| Commit history দেখা                  | `git log --oneline --graph --decorate --all` |
| Main branch-এ যাওয়া                  | `git switch main`                            |
| Feature branch merge                 | `git merge branch-name`                      |
| Remote Main update                   | `git push origin main`                       |

---

# 36. আমার Recommended Final Workflow

যদি কোনো developer-এর branch `main`-এ merge করার জন্য যাচাই করতে হয়, আমি এই sequence অনুসরণ করব:

```bash
# ==========================================
# PHASE 1: Prepare
# ==========================================

git fetch --all

git switch sajib/requirement

git status

git pull


# ==========================================
# PHASE 2: Sync with Main
# ==========================================

git merge origin/main


# ==========================================
# PHASE 3: Verify
# ==========================================

flutter pub get

flutter analyze

flutter test

flutter build apk --debug


# ==========================================
# PHASE 4: Manual Testing
# ==========================================

# Application চালিয়ে manually test করুন


# ==========================================
# PHASE 5: Merge to Main
# ==========================================

git switch main

git pull origin main

git merge sajib/requirement


# ==========================================
# PHASE 6: Verify Main Again
# ==========================================

flutter pub get

flutter analyze

flutter test

flutter build apk --debug


# ==========================================
# PHASE 7: Push
# ==========================================

git push origin main
```

---

# Important Rule

> **Never assume that "merge successful" means "project is working".**

সঠিক workflow হলো:

```text
Branch Code
    ↓
Update with Latest Main
    ↓
Resolve Conflicts
    ↓
Build
    ↓
Test
    ↓
Analyze / Lint
    ↓
Manual Test
    ↓
Merge to Main
    ↓
Test Main Again
    ↓
Push
```

এভাবে কাজ করলে কোনো feature branch `main`-এ merge করার আগে branch-level সমস্যা এবং `main` integration সমস্যা—দুটিই শনাক্ত করার সুযোগ থাকবে।

---

# One-Line Summary

```text
Fetch → Switch → Pull → Merge Main into Branch → Resolve Conflicts → Build → Test → Analyze → Manual Test → Merge into Main → Test Main Again → Push
```
