# Season — User Data Map & Privacy Architecture

**Last updated:** 21 April 2026
**Audience:** Engineering, Product, Legal

---

## Principle

Season users are identified by **name and email for one purpose only: account access and recovery.**

Every piece of health data, behavioural data, and content interaction is stored and queried by **user_id alone** — never by name or email. The goal is that a data exposure of the health database reveals nothing that identifies a real person.

This is not an aspiration — it is the documented architecture target and the standard against which every future schema change, export, and integration must be assessed.

---

## Data Classification

Four tiers. Handling rules differ per tier.

| Tier | Label | Definition | Examples |
|------|-------|-----------|---------|
| 1 | **Identity** | Directly identifies the user | `email`, `name` |
| 2 | **Health (Special Category)** | GDPR Article 9 — highest protection | cycle data, contraception, symptoms, sexual activity, weight, temperature |
| 3 | **Behavioural** | Usage patterns, content read | phase content viewed, streaks, calendar events |
| 4 | **System** | Infrastructure/auth only | encrypted password, tokens, OAuth UIDs, timestamps |

---

## Full Data Inventory

### Table: `users` (Identity + Auth + Health — current state)

| Column | Tier | Purpose | Privacy note |
|--------|------|---------|-------------|
| `id` | System | Internal PK | Never exposed externally |
| `email` | **Identity** | Login, account recovery | Tier 1 — guard in all exports/admin |
| `name` | **Identity** | Personalisation | Tier 1 — guard in all exports/admin |
| `encrypted_password` | System | Auth | Never readable |
| `birthday` | **Health** | Age-based cycle insight | Should move to health profile (see below) |
| `last_period_start` | **Health** | Cycle calculation | Should move to health profile |
| `cycle_length` | **Health** | Cycle calculation | Should move to health profile |
| `period_length` | **Health** | Cycle display | Should move to health profile |
| `has_regular_cycle` | **Health** | Onboarding context | Should move to health profile |
| `contraception_type` | **Health** | Birth control tracking | Should move to health profile |
| `uses_hormonal_birth_control` | **Health** | Cycle context | Should move to health profile |
| `food_preference` | **Health** | Nutrition tips | Should move to health profile |
| `life_stage` | **Health** | App context | Should move to health profile |
| `language` | Behavioural | i18n preference | Low sensitivity |
| `plan` | System | Subscription tier | Low sensitivity |
| `google_uid`, `facebook_uid`, `apple_uid` | System | OAuth | Never expose |
| `invite_token` | System | Invite flow | Rotate after use |
| `admin` | System | Access control | Never expose |
| Devise tokens (`reset_password_token` etc.) | System | Auth | Expire, never log |

> **Current problem:** Tier 1 (Identity) and Tier 2 (Health) columns are co-located in the `users` table. A single table breach exposes both. See Target Architecture below.

---

### Table: `symptom_logs` — Health (Special Category)

| Column | Tier | Notes |
|--------|------|-------|
| `user_id` | System | FK only — no PII |
| `date` | Health | Date of log |
| `mood` | **Health** | Integer score |
| `energy` | **Health** | Integer score |
| `sleep` | **Health** | Integer score |
| `physical` | **Health** | Integer score |
| `mental` | **Health** | Integer score |
| `pain` | **Health** | Integer score |
| `cravings` | **Health** | Integer score |
| `discharge` | **Health** | Integer score |
| `temperature` | **Health** | Decimal — basal body temperature |
| `weight` | **Health** | Decimal — body weight |
| `notes` | **Health** | Free text — can contain PII if user writes name/details |
| `sexual_intercourse` | **Health** | Boolean — highly sensitive |

> `notes` is the only free-text health field. It must never be indexed, searched across users, or included in bulk exports.

---

### Table: `cycle_entries` — Health (Special Category)

| Column | Tier | Notes |
|--------|------|-------|
| `user_id` | System | FK only |
| `date` | Health | Calendar date |
| `phase` | Health | menstrual/follicular/ovulation/luteal |
| `season_name` | Health | winter/spring/summer/autumn |
| `cycle_day` | Health | Day number in cycle |
| `period_start` | **Health** | Menstruation marker — sensitive |
| `period_end` | **Health** | Menstruation marker — sensitive |

---

### Table: `calendar_events` — Behavioural

| Column | Tier | Notes |
|--------|------|-------|
| `user_id` | System | FK only |
| `title` | Behavioural | Free text — treat as sensitive |
| `date`, `start_time`, `end_time` | Behavioural | Appointment timing |
| `notes` | Behavioural | Free text |
| `category` | Behavioural | Event type |

> Calendar event titles and notes are user-authored free text. Treat as potentially sensitive. Never search across users or include in admin views without explicit reason.

---

### Table: `superpower_logs` — Behavioural

| Column | Tier | Notes |
|--------|------|-------|
| `user_id` | System | FK only |
| `date` | Behavioural | Date of log |

---

### Table: `streaks` — Behavioural

Linked to `user_id`. Streak counts and milestones — low sensitivity, no health content.

---

### Table: `feedbacks` — Identity-linked (requires care)

| Column | Tier | Notes |
|--------|------|-------|
| `user_id` | System | FK — links message to user |
| `type` | System | feedback / bug_report / support |
| `message` | **Identity** | Free text written by user — may contain PII, health detail |
| `attachment` / `screenshot_url` | Varies | May contain screen content |

> Feedback messages can contain anything the user writes. They are intentionally linked to `user_id` so support can respond. They must not be included in any aggregated analytics or bulk exports.

---

### Table: `launch_signups` — Identity (Pre-auth)

| Column | Tier | Notes |
|--------|------|-------|
| `email` | **Identity** | Waitlist only |

> No health data. Used only for launch notification. Delete or anonymise after first email send.

---

### Table: `cycle_phase_contents` — System/Content

Static educational content — no user data. No privacy concern.

---

## Target Architecture: Health Data Segregation

### The Problem Now

```
users table
├── email          ← Identity
├── name           ← Identity
├── birthday       ← Health
├── last_period_start  ← Health (Special Category)
├── contraception_type ← Health (Special Category)
└── ...
```

A single SQL query `SELECT * FROM users` exposes both identity and health data together. Breach of one = breach of both.

### The Target

```
users table (Identity + Auth only)
├── id
├── email
├── name
├── encrypted_password
├── [devise tokens]
└── [oauth uids]

user_health_profiles table (Health only, FK: user_id)
├── user_id         ← joins to users.id, never to email/name
├── birthday
├── last_period_start
├── cycle_length
├── period_length
├── has_regular_cycle
├── contraception_type
├── uses_hormonal_birth_control
├── food_preference
├── life_stage
├── language
└── plan
```

**Effect:** The health database can be queried, exported, or analysed using `user_id` only. Joining it back to a real name or email requires an explicit second query against the identity table — a deliberate step, not a default.

---

## Pseudonymous ID

Add a `uuid` (random v4) to each user. This becomes the **external reference** used in:

- Admin CSV exports
- Any future analytics
- Error tracking (Sentry — never log email in breadcrumbs)
- Trello feedback cards (currently forwarded with `user_id` — should use UUID)

The UUID is not guessable and is not the database primary key. Knowing a UUID gives you no route to email or name without direct database access.

```ruby
# Migration target
add_column :users, :public_id, :uuid, default: -> { "gen_random_uuid()" }, null: false
add_index :users, :public_id, unique: true
```

---

## Data Flow: What Gets Collected, When

| User Action | Data Collected | Table | Tier |
|-------------|---------------|-------|------|
| Signs up | email, name, encrypted password | users | Identity + System |
| OAuth sign-in | email, name, provider UID | users | Identity + System |
| Onboarding step 1 | name (if not set) | users | Identity |
| Onboarding step 2 | birthday | users → health profile | Health |
| Onboarding step 3 | has_regular_cycle | users → health profile | Health |
| Onboarding step 4 | cycle_length | users → health profile | Health |
| Onboarding step 5–7 | contraception type, reminder prefs | users → health profile | Health |
| Onboarding step 8 | contraception_type | users → health profile | Health |
| Onboarding step 9 | food_preference | users → health profile | Health |
| Onboarding step 10 | last_period_start | users → health profile | Health |
| Onboarding step 11 | cycle_stage_reminder, birth_control_reminder | users → health profile | Health |
| Daily symptom log | mood, energy, sleep, physical, mental, pain, cravings, discharge, notes, temperature, weight, sexual_intercourse | symptom_logs | Health |
| Period tracking | phase, cycle_day, period_start, period_end | cycle_entries | Health |
| Calendar event | title, date, times, notes, category | calendar_events | Behavioural |
| Reads phase content | (nothing stored currently) | — | — |
| Views superpower | (nothing stored currently) | — | — |
| Logs superpower | date | superpower_logs | Behavioural |
| Sends feedback | message, optional screenshot | feedbacks | Identity-adjacent |
| Uploads avatar | image file | active_storage | Identity |

---

## Rules for Engineers

These apply to every PR that touches data:

1. **Health queries use `user_id` only.** Never query `symptom_logs`, `cycle_entries`, or any health table by joining against `email` or `name`. Scope always via `current_user.id`.

2. **Admin views truncate PII.** Email in admin displays as `n***@gmail.com`. Name shows first name only. Full values only on the user detail page, not in lists or exports.

3. **CSV exports use UUID, not email.** The `export_csv` actions in `Admin::InboxController` and `Admin::LaunchSignupsController` must reference `public_id` once it exists. Until then, truncate email.

4. **Feedback cards to Trello exclude health content.** The `TrelloMailer` sends the feedback message — fine. It must never append cycle phase, symptom data, or health profile fields.

5. **Sentry / error logging must not capture health payloads.** Add `config.filter_parameters` to exclude `symptom_log`, `cycle_entry`, `last_period_start`, `contraception_type`, `birthday` from logs.

6. **Free-text fields (`notes`, `message`, `title`) are never searched across users.** No admin full-text search against user-authored content.

7. **Right to erasure is implementable.** Deleting a user must cascade-destroy all health tables (`dependent: :destroy` is already set). The account shell (email only) can optionally be retained for suppression lists — but no health data survives.

8. **Consent is captured at onboarding.** The current onboarding collects health data after the user explicitly chooses to continue. Document the consent moment in the Terms and Privacy Policy.

---

## Compliance Reference

| Regulation | Applies | Key Requirement | Current Status |
|-----------|---------|----------------|---------------|
| GDPR (EU) | Yes | Article 9: health data requires explicit consent + data minimisation | Consent via onboarding ✅ — segregation ⚠️ target |
| UK GDPR | Yes | Same as GDPR | Same |
| App Store (Apple) | Yes | Privacy nutrition label must list all data types collected | Labels needed before submission |
| Google Play | Yes | Data safety section required | Form needed before submission |
| CCPA (California) | If US users | Right to know + delete | Delete cascade ✅ |

### Data to declare for App Store / Play Store

**Data linked to identity:**
- Name
- Email address

**Health & fitness data (linked to identity):**
- Menstrual cycle data
- Body measurements (weight, temperature)
- Symptoms

**User content (linked to identity):**
- Calendar events

**App activity:**
- In-app usage (streaks, phase views)

---

## Migration Priorities

| Priority | Action | Effort | Blocks |
|---------|--------|--------|--------|
| P1 | Add `public_id` UUID to `users` | 30 min | Admin exports, Sentry config |
| P1 | `filter_parameters` for health fields in logs | 15 min | Compliance |
| P2 | Truncate email in admin list views | 30 min | GDPR admin access |
| P2 | Create `user_health_profiles` table + migration | 2 hrs | Full segregation |
| P3 | Move health columns from `users` to `user_health_profiles` | 3 hrs | Requires P2 |
| P3 | Update Trello card mailer to use UUID, strip health data | 30 min | Data minimisation |
| P4 | App Store / Play Store privacy disclosures | 1 hr | Store submission |
