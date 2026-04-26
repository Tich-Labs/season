# Season App — Developer Documentation & Auth Security Review

**Generated:** 2026-04-24 — **Last updated:** 2026-04-26
**Rails version:** 8.1.3
**Ruby version:** >= 3.4.7
**Database:** PostgreSQL (all environments)
**Deployment:** Render (free tier)

---

## Table of Contents

1. [App Purpose & Core Features](#1-app-purpose--core-features)
2. [Tech Stack](#2-tech-stack)
3. [Database Schema & Models](#3-database-schema--models)
4. [Routes & Controller Structure](#4-routes--controller-structure)
5. [Key Services & Business Logic](#5-key-services--business-logic)
6. [Auth Flow](#6-auth-flow)
7. [Admin Panel](#7-admin-panel)
8. [Mailer Setup](#8-mailer-setup)
9. [Deployment (Render)](#9-deployment-render)
10. [Notable Patterns & Architecture Decisions](#10-notable-patterns--architecture-decisions)
11. [Auth Flow Security Review](#11-auth-flow-security-review)

---

## 1. App Purpose & Core Features

Season is a menstrual cycle tracking app targeted at users who want to understand their body through a seasonal/cyclical lens. Each phase of the menstrual cycle is mapped to a season (Winter, Spring, Summer, Autumn) with associated superpowers, symptoms, and educational content.

### Core Features

| Feature | Description |
|---------|-------------|
| Cycle tracking | Log period start dates; calculates current phase and cycle day automatically |
| Symptom logging | Daily mood, energy, sleep, physical, mental, pain, cravings, discharge, temperature, weight, notes |
| Superpower tracking | Phase-specific strengths rated per day, stored as JSONB |
| Calendar | Monthly and weekly views with cycle phase colours and user events |
| Phase education | `/informations` — content per phase (nutrition, sport, mood, superpowers, take care) |
| Daily view | Single-day overview combining phase data, events, and symptom log |
| Streaks | Consecutive daily tracking counter with flame milestones |
| Appointments/Events | User-created calendar events with title, time, category, notes |
| Reminders | Supplement, pill, period, morning/evening reminder records (data model exists; UI in M5) |
| Settings | Profile, subscription, calendar display, notifications |
| Launch waitlist | Pre-launch email signup (unauthenticated) |
| Feedback/Bugs/Support | In-app form forwarded to admin inbox and Trello via email |
| Invite flow | Token-based invite link for setting password before onboarding |

### Supported Languages

- English (`en`) — primary
- German (`de`)
- Spanish (`es`) — locale file present; completeness unknown

---

## 2. Tech Stack

### Framework & Runtime

| Component | Choice | Notes |
|-----------|--------|-------|
| Framework | Rails 8.1.3 | `config.load_defaults 8.0` |
| Ruby | >= 3.4.7 | Specified in Gemfile and render.yaml |
| Database | PostgreSQL (`pg ~> 1.5`) | Extensions: `pgcrypto` (for UUID), `plpgsql` |
| Asset pipeline | Propshaft | No Sprockets |
| JS delivery | importmap-rails | No bundler/webpack |
| Frontend reactivity | Hotwire (Turbo + Stimulus) | No JS framework |
| CSS | Tailwind CSS 3.3.1 | `tailwindcss-rails` gem; custom brand tokens in `tailwind.config.js` |
| Background jobs | Solid Queue | Runs in-process via Puma plugin (`SOLID_QUEUE_IN_PUMA=true`) |
| Caching | Solid Cache | PostgreSQL-backed |

### Authentication & Authorization

| Component | Choice |
|-----------|--------|
| Auth library | Devise (`database_authenticatable`, `registerable`, `recoverable`, `rememberable`, `validatable`, `confirmable`, `omniauthable`) |
| Session management | Custom `Authentication` concern (session + encrypted cookie, not Devise sessions) |
| OmniAuth | Google OAuth2, Facebook, Apple |
| Admin gate | `User#admin?` boolean column, checked in `Admin::BaseController` |

### Key Gems

| Gem | Purpose |
|-----|---------|
| `devise` | Password reset, confirmable, OmniAuth scaffolding |
| `omniauth-google-oauth2`, `omniauth-facebook`, `omniauth-apple` | Social login |
| `resend` | Transactional email delivery in production |
| `stripe` | Payments (gem present; not yet wired in controllers) |
| `sentry-ruby` + `sentry-rails` | Error tracking |
| `pagy` | Pagination (used in admin users list via manual offset/limit) |
| `ransack` | Admin user search |
| `groupdate` | Present in Gemfile; not actively used in controllers |
| `httparty` | HTTP client (present; not used in app code reviewed) |
| `bcrypt` | Password hashing via Devise |
| `solid_queue` + `solid_cache` | PostgreSQL-backed job/cache adapters |
| `kamal` | Docker deployment tooling (not used on Render; present for future) |
| `better_errors`, `pry-byebug` | Dev tooling |
| `rspec-rails`, `factory_bot_rails`, `faker`, `capybara` | Test infrastructure (tests not yet written) |

### Development Tooling

- `letter_opener` for email preview locally
- RuboCop with rails-omakase, performance, rspec, capybara rulesets
- `brakeman` for static security analysis
- `database_consistency` for schema/model alignment checks
- `erb_lint` for ERB linting
- `dotenv-rails` for local environment variable management

---

## 3. Database Schema & Models

### Schema version

`20260421100104` (PostgreSQL, `ActiveRecord::Schema[8.1]`)

### Models & Associations

#### `User`

Central model. Owns all user data.

```
users
  id                        bigserial PK
  public_id                 uuid NOT NULL UNIQUE (gen_random_uuid())
  email                     string NOT NULL UNIQUE
  encrypted_password        string NOT NULL
  name                      string NOT NULL
  admin                     boolean DEFAULT false NOT NULL
  language                  string DEFAULT 'en' NOT NULL
  plan                      string DEFAULT 'free'
  onboarding_completed      boolean DEFAULT false NOT NULL

  -- Cycle data
  last_period_start         date
  cycle_length              integer
  period_length             integer
  has_regular_cycle         boolean
  uses_hormonal_birth_control boolean
  contraception_type        string DEFAULT 'none'
  birth_control_reminder    boolean
  cycle_stage_reminder      boolean
  life_stage                string DEFAULT 'menstrual'

  -- Profile
  birthday                  date
  food_preference           string
  avatar_url                string

  -- Devise fields
  reset_password_token      string UNIQUE (indexed)
  reset_password_sent_at    datetime
  remember_created_at       datetime
  confirmation_token        string
  confirmed_at              datetime
  confirmation_sent_at      datetime
  unconfirmed_email         string

  -- OAuth UIDs
  google_uid                string
  facebook_uid              string
  apple_uid                 string

  -- Invite
  invite_token              string (indexed)
  invite_accepted_at        datetime
```

**Associations:**

- `has_one_attached :avatar` (Active Storage)
- `has_many :cycle_entries, dependent: :destroy`
- `has_many :calendar_events, dependent: :destroy`
- `has_many :symptom_logs, dependent: :destroy`
- `has_many :superpower_logs, dependent: :destroy`
- `has_many :reminders, dependent: :destroy`
- `has_many :feedbacks, dependent: :destroy`
- `has_one :streak, dependent: :destroy`

**Key methods:**

| Method | Description |
|--------|-------------|
| `current_phase` | Delegates to `CycleCalculatorService`; returns nil if no `last_period_start` |
| `current_cycle_day` | `(today - last_period_start).to_i + 1`; nil if no period date |
| `onboarding_completed?` | Boolean check; used everywhere for auth gate |
| `first_incomplete_onboarding_step` | Returns step integer (1–11) or nil |
| `profile_complete?` | All required onboarding fields present |
| `first_name` | First word of `name` |
| `self.find_or_create_from_oauth(provider, auth)` | Upsert for OAuth users |
| `self.ransackable_attributes` | Limits ransack search fields to safe set |

**Devise modules:** `database_authenticatable`, `registerable`, `recoverable`, `rememberable`, `validatable`, `confirmable`, `omniauthable`

---

#### `CycleEntry`

One record per cycle day per user. Tracks phase assignments.

```
cycle_entries
  id            bigserial PK
  user_id       bigint FK NOT NULL
  date          date NOT NULL
  phase         string NOT NULL  -- menstrual|follicular|ovulation|luteal
  season_name   string
  cycle_day     integer
  period_start  boolean DEFAULT false NOT NULL
  period_end    boolean DEFAULT false NOT NULL
  UNIQUE INDEX on (user_id, date)
```

Phases validated against `PHASES = %w[menstrual follicular ovulation luteal]`.
Scopes: `for_month(year, month)`, `ordered`.

---

#### `SymptomLog`

One record per day per user. Integer scale ratings (1–5 implied) for each metric.

```
symptom_logs
  id                  bigserial PK
  user_id             bigint FK NOT NULL
  date                date NOT NULL
  mood                integer
  energy              integer
  sleep               integer
  physical            integer
  mental              integer
  pain                integer
  cravings            integer
  discharge           integer
  sexual_intercourse  boolean DEFAULT false NOT NULL
  temperature         decimal
  weight              decimal
  notes               text
  UNIQUE INDEX on (user_id, date)
```

`TRACKABLE = %w[mood energy sleep physical mental pain cravings discharge]`

---

#### `SuperpowerLog`

One record per day per user. Ratings stored as a JSONB hash keyed by superpower name.

```
superpower_logs
  id        bigserial PK
  user_id   bigint FK NOT NULL
  date      date NOT NULL
  ratings   jsonb
  UNIQUE INDEX on (user_id, date)
```

---

#### `CalendarEvent`

User-created events with optional start/end times.

```
calendar_events
  id          bigserial PK
  user_id     bigint FK NOT NULL
  title       string NOT NULL
  date        date NOT NULL
  start_time  time
  end_time    time
  category    string
  notes       text
  INDEX on (user_id, date)
```

---

#### `Streak`

One record per user. Tracks consecutive tracking days.

```
streaks
  id                bigserial PK
  user_id           bigint FK NOT NULL UNIQUE
  current_streak    integer DEFAULT 0
  longest_streak    integer DEFAULT 0
  total_flames      integer DEFAULT 0
  last_tracked_date date
```

Milestones: `[30, 50, 75, 100, 125]`. Logic in `increment_streak!`: increments if yesterday was last tracked; resets to 1 otherwise; no-ops if today already tracked.

---

#### `Reminder`

Notification schedule for pill, period, morning, evening reminders.

```
reminders
  id              bigserial PK
  user_id         bigint FK NOT NULL
  name            string
  reminder_type   string  -- supplement|pill|period_start|period_end|morning|evening
  time            time
  active          boolean DEFAULT false NOT NULL
  message         text
  pill_days       integer
  break_days      integer
  INDEX on (user_id, active)
```

No background job delivery wired yet; data model is in place for M5.

---

#### `Feedback`

Unified inbox for feedback, bug reports, and support messages.

```
feedbacks
  id              bigserial PK
  user_id         bigint FK NOT NULL
  type            string DEFAULT 'feedback' NOT NULL  -- feedback|bug_report|support
  message         text NOT NULL
  active          boolean DEFAULT true NOT NULL
  attachment      string
  screenshot_url  string
```

- `self.inheritance_column = nil` (uses `type` as a plain enum, not STI)
- `after_create_commit :forward_to_trello` — enqueues `TrelloMailer.card(self).deliver_later`
- Has one attached `:media` (Active Storage)

---

#### `LaunchSignup`

Simple waitlist email capture.

```
launch_signups
  id          bigserial PK
  email       string
  created_at  datetime NOT NULL
  updated_at  datetime NOT NULL
```

---

#### `CyclePhaseContent`

CMS-style educational content per phase and locale. Seeded, not user-created.

```
cycle_phase_contents
  id               bigserial PK
  phase            string NOT NULL
  locale           string NOT NULL
  season_name      string
  mood_text        text
  nutrition_text   text
  sport_text       text
  superpower_text  text
  take_care_text   text
  UNIQUE INDEX on (phase, locale)
```

`.for(phase, locale)` falls back to `en` locale if the requested locale has no record.

---

#### `Current`

`ActiveSupport::CurrentAttributes` with a single `user` attribute. Set on login, cleared on logout. Used in `current_user` helper.

---

### Active Storage

Standard Rails 8 Active Storage tables (`active_storage_blobs`, `active_storage_attachments`, `active_storage_variant_records`). Storage service: `:local` in all environments (configured in `production.rb`). Used for user avatar uploads and feedback media attachments.

---

## 4. Routes & Controller Structure

### Public / Unauthenticated Routes

| Method | Path | Controller#Action | Notes |
|--------|------|-------------------|-------|
| GET | `/` | `home#welcome` | Root; redirects to `/welcome` |
| GET | `/welcome` | `home#welcome` | Landing / splash |
| GET | `/app` | `home#app` | Smart redirect: authenticated → calendar or onboarding; unauthenticated → welcome |
| GET | `/loader` | `home#loader` | App loader screen |
| GET | `/launch` | `launch#index` | Launch / countdown page |
| GET | `/countdown` | `home#countdown` | Countdown variant |
| GET | `/terms` | `legal#terms` | Terms of service |
| GET | `/privacy` | `legal#privacy` | Privacy policy |
| GET | `/invite/:token` | `invites#show` | Invite landing |
| PATCH | `/invite/:token` | `invites#update` | Set password via invite |
| POST | `/launch-signup` | `launch_signups#create` | Waitlist form (JSON response) |
| GET | `/manifest.json` | `pwa#manifest` | PWA manifest |
| GET | `/service-worker.js` | `pwa#service_worker` | PWA service worker |
| GET | `/up` | `rails/health#show` | Health check |
| GET | `/ping` | inline proc | Lightweight liveness check |

### Auth Routes

| Method | Path | Controller#Action | Notes |
|--------|------|-------------------|-------|
| GET | `/registration/new` | `registrations#new` | Sign-up form |
| POST | `/registration` | `registrations#create` | Create account |
| GET | `/session/new` | `sessions#new` | Sign-in form |
| POST | `/session` | `sessions#create` | Authenticate |
| DELETE | `/session` | `sessions#destroy` | Sign out |
| GET | `/users/password/new` | Devise `passwords#new` | Request password reset email |
| POST | `/users/password` | Devise `passwords#create` | Send reset email (overridden to custom `PasswordsController`) |
| GET | `/users/password/edit` | Devise `passwords#edit` | Password reset form (from email link) |
| PATCH | `/users/password` | Devise `passwords#update` | Submit new password |
| GET | `/password/done` | `passwords#done` | Success page after reset request |
| GET | `/password/error/already-reset` | `passwords#error_already_reset` | Rate-limit messaging |
| GET | `/password/error/link-expired` | `passwords#error_link_expired` | Token invalid/expired |
| GET | `/password/error/wrong-email` | `passwords#error_wrong_email` | Email not found messaging |
| GET | `/password/error/inbox-full` | `passwords#error_inbox_full` | Delivery error info |
| GET | `/password/error/contact` | `passwords#error_contact` | Generic delivery failure |
| GET | `/auth/failure` | `omniauth#failure` | OAuth failure handler |
| GET/POST | `/auth/:provider/callback` | `omniauth#callback` | OAuth callback |

### Onboarding Routes

| Method | Path | Controller#Action |
|--------|------|-------------------|
| GET | `/onboarding/:id` | `onboarding#show` |
| PATCH | `/onboarding/:id` | `onboarding#update` |
| GET | `/onboarding/finish` | `onboarding#finish` |

### Authenticated App Routes

| Method | Path | Controller#Action |
|--------|------|-------------------|
| GET | `/calendar` | `calendar#index` (also `:user_root`) |
| GET | `/calendar/weekly` | `calendar#weekly` |
| GET | `/calendar/appointments` | `calendar#appointments` |
| GET/POST/PATCH/DELETE | `/calendar_events/*` | `calendar_events#*` |
| GET | `/daily/:date` | `daily_view#show` |
| GET | `/tracking` | `tracking#index` |
| POST | `/tracking` | `tracking#create` |
| GET | `/tracking/period` | `tracking#period` |
| PATCH | `/tracking/period` | `tracking#period_update` |
| GET | `/symptoms` | `symptoms#index` |
| GET | `/symptoms/:id` | `symptoms#show` |
| POST | `/symptoms` | `symptoms#create` |
| PATCH | `/symptoms/:id` | `symptoms#update` |
| GET | `/symptoms/discharge` | `symptoms#discharge` |
| GET | `/superpowers` | `superpowers#index` |
| GET | `/superpowers/:id` | `superpowers#show` |
| POST | `/superpowers` | `superpowers#create` |
| PATCH | `/superpowers/:id` | `superpowers#update` |
| GET | `/streaks` | `streaks#index` |
| GET | `/informations` | `informations#index` |
| GET | `/informations/:phase` | `informations#show` |
| POST | `/feedbacks` | `feedbacks#create` |
| GET/PATCH | `/settings/edit` | `settings#edit/update` |
| GET | `/settings/profile` | `settings#profile` |
| GET | `/settings/subscriptions` | `settings#subscriptions` |
| GET | `/settings/calendar` | `settings#calendar` |
| GET | `/settings/notifications` | `settings#notifications` |
| PATCH | `/settings/update_avatar` | `settings#update_avatar` |
| PATCH | `/settings/update_profile` | `settings#update_profile` |
| PATCH | `/settings/update_notifications` | `settings#update_notifications` |

### Admin Routes

All under `/admin`, gated by `Admin::BaseController` requiring `current_user.admin?`.

| Method | Path | Controller#Action |
|--------|------|-------------------|
| GET | `/admin` | `admin/users#index` (root) |
| GET | `/admin/users` | `admin/users#index` |
| GET | `/admin/users/:id` | `admin/users#show` |
| GET | `/admin/inbox` | `admin/inbox#overview` |
| GET | `/admin/inbox/feedback` | `admin/inbox#feedback` |
| GET | `/admin/inbox/bugs` | `admin/inbox#bugs` |
| GET | `/admin/inbox/support` | `admin/inbox#support` |
| GET | `/admin/inbox/export_csv` | `admin/inbox#export_csv` |
| GET | `/admin/launch_signups` | `admin/launch_signups#index` |
| GET | `/admin/launch_signups/export_csv` | `admin/launch_signups#export_csv` |

### Debug/Test Routes (Production Risk)

The following routes are defined directly in `routes.rb` and remain active in production:

| Path | What it does |
|------|-------------|
| `/test-db` | Returns Rails env string |
| `/test-load` | Attempts to load `RegistrationsController`, returns load status |
| `/test` | `debug#test` action |
| `/model-test` | Runs `User.count` and returns result |
| `/i18n-test` | Runs an I18n lookup and returns result |
| `/env` | **Returns environment variable presence** (DATABASE_URL, RAILS_MASTER_KEY, SECRET_KEY_BASE) |

> **Security concern:** `/env` discloses whether sensitive environment variables are set. While it does not expose the values, this is operational information that should not be publicly accessible.

---

## 5. Key Services & Business Logic

### `CycleCalculatorService`

Located at `app/services/cycle_calculator_service.rb`. The single source of truth for all cycle phase calculations.

**Initialization:** Takes a `User` instance. Reads `cycle_length` (default 28), `period_length` (default 5), `last_period_start`, and whether the user is on hormonal contraception.

**Phase boundary algorithm:**

```
cycle_day = ((date - last_period_start).to_i % cycle_length) + 1

menstrual:  cycle_day <= period_length
follicular: cycle_day <= cycle_length - 14
ovulation:  cycle_day <= cycle_length - 14 + 7
luteal:     remainder
```

**Hormonal BC handling:** Users on pill, hormone ring, or plaster (`HORMONAL_BC_TYPES`) have ovulation and luteal phases collapsed into follicular, since those phases are biochemically suppressed.

**Key methods:**

| Method | Returns |
|--------|---------|
| `current_phase` | `"menstrual"`, `"follicular"`, `"ovulation"`, `"luteal"`, or `nil` |
| `current_cycle_day` | Integer day number within current cycle |
| `phase_for_date(date)` | Phase string for any date |
| `effective_phase_for_date(date)` | Phase with hormonal BC collapsing applied |
| `colour_for_date(date)` | Hex colour string from `PHASE_COLOURS` |
| `month_data(year, month)` | Array of hashes per day: `{date, phase, season, colour, cycle_day}` |
| `week_data(week_start)` | Same structure for a 7-day window |
| `strip_data(past_days:, future_days:)` | Centred window for day strip widget |
| `wheel_arcs` | SVG arc data (start/end angle per phase) for the donut wheel |

**`PHASE_META`** constant is used directly in views and controllers to retrieve colours and season names without instantiating the service.

---

### Streak Logic (`Streakable` concern + `Streak` model)

The `Streakable` concern is included in `SymptomsController` and `SuperpowersController`. Calling `update_streak!` in those controllers' `create` actions links tracking activity to streak increments.

`Streak#increment_streak!` is idempotent for the same day (returns early if `last_tracked_date == today`).

---

### Onboarding Flow

11-step wizard. Step numbering is significant: steps 4, 10, and 11 are skippable. Steps 6 and 7 are only shown if the user said "yes" to hormonal contraception at step 5 (otherwise goes to step 8). Step data is persisted to the User record at each step (no draft state).

`REQUIRED_ONBOARDING_STEPS` in the `User` model defines which steps produce a blocking nil if skipped wrongly. `first_incomplete_onboarding_step` drives the `require_onboarding_completed` guard in `Authentication`.

---

## 6. Auth Flow

### Architecture Overview

The app uses a **hybrid approach**: Devise for its recoverable/confirmable/omniauthable infrastructure and token handling, but a **custom `Authentication` concern** for the actual session management. Devise's own session controller is not used.

This means:
- Sign up, sign in, sign out are handled entirely by custom controllers (`RegistrationsController`, `SessionsController`).
- Password reset uses a custom `PasswordsController` that wraps Devise's token logic (`User.with_reset_password_token`, `user.send_reset_password_instructions`).
- OmniAuth callbacks go through a custom `OmniauthController`.
- Devise handles confirmable emails, token generation/validation, and OmniAuth middleware mounting.

---

### Sign Up

**Controller:** `RegistrationsController#create`
**Layout:** `launch`

Flow:
1. Check for existing email — if found, render inline error (`:already_registered`).
2. Build `User` with `email`, `password`, `password_confirmation`, `name` (falls back to email prefix if blank).
3. On `save`: `login(user)` sets session + encrypted cookie, redirects to `onboarding_path(1)`.
4. On failure: render `:new` with `status: :unprocessable_content`.

Email confirmable is enabled (`confirmable` Devise module). However, the registration flow logs the user in immediately after saving, before email confirmation. This means:
- A user can access the app without confirming their email.
- `allow_unconfirmed_access_for` is not set in `devise.rb` (defaults to 0 days), but since the login uses the custom `Authentication#login` method (not Devise's `sign_in`), Devise's unconfirmed access guard does not apply.

---

### Sign In

**Controller:** `SessionsController#create`
**Layout:** `launch`

Flow:
1. Rate limit check (IP-based, 5 attempts per 15 minutes via `Rails.cache`).
2. Look up user by `email.downcase`.
3. `user.valid_password?(password)` — Devise bcrypt check.
4. On success: `reset_login_attempts`, `login(user)`, redirect to `after_sign_in_path`.
5. On failure: increment attempt counter, set `@error_type`, render `:new`.

`after_sign_in_path` returns `onboarding_path(step)` if any required onboarding step is incomplete, otherwise `user_root_path` (`/calendar`).

---

### `Authentication#login` (Session Setup)

```ruby
def login(user)
  reset_session                          # Prevents session fixation
  session[:user_id] = user.id
  cookies.encrypted[:user_id] = {
    value: user.id,
    expires: VALID_SESSION_DAYS.days.from_now,   # 7 days
    httponly: true,
    secure: Rails.env.production?,
    same_site: :lax
  }
  Current.user = user
end
```

- `reset_session` before writing — prevents session fixation attacks.
- Dual-storage: `session[:user_id]` (short-lived Rails session cookie) and `cookies.encrypted[:user_id]` (persistent 7-day encrypted cookie).
- `current_user` reads from `session[:user_id]` first, falls back to `cookies.encrypted[:user_id]`.

---

### Sign Out

**Controller:** `SessionsController#destroy`

```ruby
def logout
  reset_session
  cookies.delete(:user_id)
  Current.user = nil
end
```

Signs out, clears all session data, deletes persistent cookie. Redirects to `root_path`.

Devise's `expire_all_remember_me_on_sign_out = true` is configured but only applies if Devise's own `remember_me` is used — the custom cookie approach means Devise's remember_me is not in play. The custom logout is correct and complete.

---

### Password Reset

**Controller:** `PasswordsController` (custom, not Devise's default)

#### Step 1 — Request (`new`, `create`)

- `new`: renders the "enter your email" form.
- `create`: Looks up user by email. If found, calls `user.send_reset_password_instructions` (Devise method — generates token, sends email). If not found, does nothing.
- **Always redirects to `done_password_path`** — does not reveal whether the email exists (enumeration protection).
- On mailer exception: logs error and redirects to `password_error_contact_path`.

#### Step 2 — Reset (`edit`, `update`)

- `edit`: `before_action :load_user_from_token` — calls `User.with_reset_password_token(params[:reset_password_token])`. If nil (expired or invalid), redirects to `password_error_link_expired_path`.
- Token expiry: **6 hours** (`config.reset_password_within = 6.hours`).
- `update`: Calls `@user.update(password:, password_confirmation:)`. On success: redirects to `new_session_path` with notice. On failure: re-renders `edit`.
- After successful reset, Devise's default `sign_in_after_reset_password = true` signs the user in — but since this is handled via Devise's `update` method chain, and the app uses custom sessions, the auto-sign-in likely does not apply. The user is redirected to sign-in manually.

#### Error Pages

| Path | Purpose |
|------|---------|
| `/password/error/link-expired` | Token nil/expired — used by `load_user_from_token` |
| `/password/error/already-reset` | Rate-limit messaging only (not triggered by token validation) |
| `/password/error/wrong-email` | User-facing email-not-found messaging (rendered separately; the `create` action does NOT redirect here — it always goes to `done`) |
| `/password/error/inbox-full` | Delivery failure hint |
| `/password/error/contact` | Fallback for `rescue` block in `create` |

> **Note:** The `error_wrong_email` and `error_already_reset` pages exist as standalone informational pages but are not automatically triggered by any controller logic. They would need manual navigation or explicit redirects to be useful.

---

### OmniAuth (Google / Facebook / Apple)

**Controller:** `OmniauthController#callback`

All three providers are configured in `devise.rb`:

```ruby
config.omniauth :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"],
  scope: "email,profile", prompt: "select_account"
config.omniauth :facebook, ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_APP_SECRET"],
  scope: "email", prompt: "select_account"
config.omniauth :apple, ENV["APPLE_CLIENT_ID"], ENV["APPLE_CLIENT_SECRET"],
  scope: "email, name"
```

**Callback flow:**

1. Extract provider from path.
2. Normalize provider string (`google_oauth2` → `google`).
3. Check `request.env["omniauth.auth"]` is present.
4. Extract email — tries `auth.info.email` first, falls back to `auth.extra.raw_info.email`.
5. If email blank: redirect to sign-in with error.
6. `User.find_or_create_from_oauth(provider, auth)` — upserts by email, writes `{provider}_uid`.
7. If user persisted: `login(user)`, redirect to `after_sign_in_path`.

`User.find_or_create_from_oauth`:

```ruby
def self.find_or_create_from_oauth(provider, auth)
  find_or_initialize_by(email: auth.info.email.downcase).tap do |user|
    user.assign_attributes(
      name: auth.info.name,
      "#{provider}_uid" => auth.uid
    )
    user.save! if user.new_record?
  end
rescue ActiveRecord::RecordInvalid
  user
end
```

- On existing user: only writes the UID if it was nil; does not change the name.
- On new user: saves the record and writes uid + name.
- CSRF protection is skipped for the callback action (`skip_before_action :verify_authenticity_token`), which is standard practice for POST callbacks from OAuth providers.

**OmniAuth failure:** `GET /auth/failure` → redirects to sign-in with "authentication failed" alert.

---

### Invite Flow

Token-based invite for new users (likely admin-generated, though the admin panel has no invite creation UI).

1. `GET /invite/:token` → `InvitesController#show`: finds user by `invite_token`, checks `invite_accepted_at` is nil, renders password-setting form.
2. `PATCH /invite/:token` → `InvitesController#update`: sets `password`, marks `invite_accepted_at`, clears `invite_token`, logs the user in, redirects to `onboarding_path(1)`.

---

### Session Security Configuration

| Setting | Value | Notes |
|---------|-------|-------|
| Session cookie name | `_season_session` | Set in `session_store.rb` |
| Session cookie same_site | `:lax` | Allows navigation flows but blocks cross-origin POST |
| Persistent cookie same_site | `:lax` | Matches session |
| Persistent cookie httponly | `true` | Not accessible to JavaScript |
| Persistent cookie secure | `true` in production | HTTPS only |
| Session fixation prevention | `reset_session` before login | Present |
| Login rate limit | 5 attempts / 15 min per IP | `Rails.cache` backed |
| Password reset window | 6 hours | Devise `reset_password_within` |
| bcrypt stretches | 12 (1 in test) | Devise default |
| CSRF | Rails default (`protect_from_forgery`) | OmniAuth callback exempt |
| CSP | Report-only mode | Via `content_security_policy_report_only = true` |

---

## 7. Admin Panel

### Access Control

`Admin::BaseController < ApplicationController` with:
- `before_action :require_admin` — checks `authenticated? && current_user.admin?`. Redirects to `root_path` if either is false.
- `before_action :set_inbox_stats` — populates `@stats` hash for sidebar badge counts.
- `layout "admin"` — uses `app/views/layouts/admin.html.erb`.

The `admin` boolean is set directly on the `User` record. There is no admin provisioning UI. Use the rake task below to bootstrap the first admin user and test accounts.

### Controllers

| Controller | Actions | Notes |
|-----------|---------|-------|
| `Admin::UsersController` | `index`, `show` | Ransack search, manual pagination (20/page), CSV export |
| `Admin::InboxController` | `overview`, `feedback`, `bugs`, `support`, `export_csv` | Filters `Feedback` by type; all share one view `admin/inbox/index` |
| `Admin::LaunchSignupsController` | `index`, `export_csv` | Launch waitlist management |

### Provisioning Admin & Test Accounts

A rake task at `lib/tasks/setup_accounts.rake` handles production bootstrapping without needing email delivery:

```
bundle exec rails setup:accounts
```

This task:
- Promotes `naijeria@gmail.com` to `admin = true` and marks the account confirmed
- Creates two test accounts (`test1@seasonapp.co`, `test2@seasonapp.co`) with password `Season2026!`, both confirmed and ready to use immediately

Run once after the first deploy, or re-run safely — it is idempotent (`find_or_initialize_by`).

### Sidebar Rules

Per CLAUDE.md: active states use `bg-[#7a2f2a] text-white`. No blue/red/purple per section. Inbox is a direct link (all messages); sub-items always visible. No JS toggles.

---

## 8. Mailer Setup

### Production Delivery

Primary: **Resend** via `resend` gem.

```ruby
# config/initializers/resend.rb
Resend.api_key = ENV["RESEND_API_KEY"]

# config/environments/production.rb
if ENV["RESEND_API_KEY"].present?
  config.action_mailer.delivery_method = :resend
  config.action_mailer.resend_api_key = ENV["RESEND_API_KEY"]
  config.action_mailer.default_options = { from: ENV.fetch("RESEND_FROM_EMAIL", "info@season.vision") }
else
  # Fallback: Gmail SMTP via ENV["SMTP_USERNAME"] / ENV["SMTP_PASSWORD"]
end
```

The `RESEND_API_KEY` is marked `sync: false` in `render.yaml` — it must be set manually in the Render dashboard.

### Development Delivery

`letter_opener` — emails open in the browser instead of being sent.

### Mailers

#### `ApplicationMailer`

Base mailer. Default `from:` reads `MAIL_FROM` env var (defaults to `info@season.vision`). Overrides `mail()` to log outgoing mail metadata.

#### `SupportMailer`

- **Action:** `support_request(feedback)`
- **To:** `SUPPORT_EMAIL` env var (`info@season.vision`)
- **Subject:** `[Season Support] {message truncated to 60 chars}`
- **Reply-to:** submitting user's email
- Not currently called from application code (present but not wired to `Feedback` after_create)

#### `TrelloMailer`

- **Action:** `card(feedback)`
- **To:** `TRELLO_EMAIL` env var (Render: `nashthecoder+hsngtakttwswmszkpwsa@boards.trello.com`)
- **Subject:** `{emoji} {type} — {user email}: {message truncated}`
- Attaches `feedback.media` if present.
- Returns early (no-op) if `TRELLO_EMAIL` is blank.
- Triggered via `Feedback#after_create_commit :forward_to_trello` → `TrelloMailer.card(self).deliver_later`

#### Devise Mailer

Devise's default mailer handles:
- Email confirmation on registration
- Password reset email (`send_reset_password_instructions`)

`config.mailer_sender` = `MAIL_FROM` env var (`info@season.vision`).

### URL Options

- Production: `host: APP_HOST` (env var, defaults to `seasonv2.onrender.com`), `protocol: "https"`.
- Development: `host: "localhost", port: 3000`.

---

## 9. Deployment (Render)

### render.yaml

Single web service + one PostgreSQL database, both on Render free tier.

| Key | Value |
|-----|-------|
| Service type | `web` |
| Runtime | `ruby` |
| Build command | `./bin/render-build.sh` |
| Start command | `bundle exec puma` |
| Health check | `/up` |
| Ruby version | `3.4.7` |
| Concurrency | `WEB_CONCURRENCY=1` (single Puma worker) |
| Solid Queue | In-process via `SOLID_QUEUE_IN_PUMA=true` |
| Active Storage | `:local` (ephemeral on Render — **files lost on redeploy**) |

### Build Script (`bin/render-build.sh`)

1. `bundle install`
2. `rails tailwindcss:build`
3. `rails assets:precompile` + `assets:clean`
4. `rails db:prepare` (migrates primary database)
5. `rails db:cache:schema:load` (Solid Cache tables)
6. `rails db:queue:schema:load` (Solid Queue tables)

Steps 5 and 6 are necessary because `db:prepare` only processes the primary database when all databases share the same `DATABASE_URL`.

### Environment Variables

| Variable | Source | Notes |
|----------|--------|-------|
| `DATABASE_URL` | Render DB `connectionString` | Auto-injected |
| `RAILS_ENV` | `production` | Static |
| `RAILS_MASTER_KEY` | `generateValue: true` | New value generated per service; **do not copy from local** |
| `SECRET_KEY_BASE` | `generateValue: true` | Auto-generated; separate from `RAILS_MASTER_KEY` |
| `RESEND_API_KEY` | `sync: false` — **manual** | Must be set in Render dashboard |
| `RESEND_FROM_EMAIL` | `noreply@season.vision` | Static |
| `SUPPORT_EMAIL` | `info@season.vision` | Static |
| `APP_HOST` | `seasonv2.onrender.com` | Used for mailer URL options |
| `TRELLO_EMAIL` | `nashthecoder+...@boards.trello.com` | Trello email-to-board address |
| `GOOGLE_CLIENT_ID/SECRET` | Not in render.yaml — **manual** | Must be added for Google OAuth |
| `FACEBOOK_APP_ID/SECRET` | Not in render.yaml — **manual** | Must be added for Facebook OAuth |
| `APPLE_CLIENT_ID/SECRET` | Not in render.yaml — **manual** | Must be added for Apple Sign In |

### SSL / HTTPS

`config.assume_ssl = true` (trusts upstream SSL termination).
`config.force_ssl = false` (disabled for Render free tier which lacks automatic HTTPS redirect).

> This means HTTP connections are not redirected to HTTPS at the Rails level. The security comment in the code acknowledges this is a Render free-tier limitation.

---

## 10. Notable Patterns & Architecture Decisions

### Custom Authentication Over Devise Sessions

Devise is used for token infrastructure (recoverable, confirmable, omniauthable) but the session mechanism is entirely custom. This gives more control over session cookie parameters, `Current.user` integration, and the dual session/cookie fallback. The tradeoff is that Devise's built-in `before_action :authenticate_user!` is not used — the `Authentication` concern replaces it.

### `require_onboarding_completed` Gate

After login, every authenticated request checks `current_user.first_incomplete_onboarding_step`. If a step is incomplete, the user is redirected to that onboarding step. This is a heavy-handed but reliable way to ensure profile completeness before the user can access the main app.

Controllers that need to bypass this gate call `skip_onboarding_requirement`. Currently applied to: `PasswordsController`.

### `Current.user` Pattern

`ActiveSupport::CurrentAttributes` stores the authenticated user for the duration of the request. Avoids per-controller `@current_user` memoization. `current_user` in `Authentication` reads from `Current.user` with a DB fallback via session/cookie.

### GDPR-Aware Parameter Filtering

`filter_parameters_logging.rb` explicitly filters health data fields (birthday, cycle data, symptoms, weight, temperature, sexual intercourse) from logs. This is a deliberate GDPR Article 9 compliance measure for health data as a special category.

### STI Disabled on Feedback

`self.inheritance_column = nil` on `Feedback` prevents Rails from treating the `type` column as STI discriminator. Feedback uses `type` as a plain enum-style string instead.

### Phase Calculation Accuracy

The phase boundary algorithm is a simplified fixed-point model (not ovulation-prediction based). Ovulation is assumed at `cycle_length - 14` (14 days before expected next period). This works for users with regular cycles but will drift for irregular cycles. There is no correction mechanism when a new period start is logged.

### No Service Objects Beyond CycleCalculatorService

Business logic lives in models and the one service class. Controllers are thin — they validate, delegate, and redirect. This follows the Rails convention over the service-layer pattern.

### Feedback to Trello Pipeline

New feedback records trigger `TrelloMailer.card(self).deliver_later` via `after_create_commit`. The Trello Power-Up "Email to Board" feature converts the email into a Trello card. This is an elegant zero-infrastructure integration — no Trello API key required.

### Solid Queue In-Process

Running Solid Queue inside Puma (no separate worker dyno) works correctly for low-traffic apps on Render free tier. Background jobs (currently only `TrelloMailer.deliver_later`) process in the same Puma process. If job volume grows or jobs become slow/blocking, a separate worker dyno would be needed.

### Ransack Scope Restriction

`User.ransackable_attributes` restricts Ransack search to `%w[email name created_at onboarding_completed language]`. `ransackable_associations` returns an empty array. This is correct security hygiene — prevents search-based data exfiltration of sensitive fields.

---

## 11. Auth Flow Security Review

### Strengths

| Area | Status |
|------|--------|
| Session fixation prevention | `reset_session` called before every `login()` — correct |
| Password hashing | bcrypt at cost 12 — industry standard |
| Login rate limiting | IP-based, 5 attempts/15 min, cache-backed |
| Email enumeration (password reset) | Always redirects to `done` regardless of email existence |
| CSRF | Rails default `protect_from_forgery`; only omniauth callback is exempt (required) |
| Parameter filtering | Health data and credentials filtered from logs |
| httponly cookie | Persistent user cookie is httponly |
| Secure cookie | Persistent cookie uses `secure: true` in production |
| OAuth CSRF (state param) | Handled by omniauth middleware automatically |
| Admin gate | Dual check: `authenticated? && current_user.admin?` |

---

### Gaps and Risks

#### 1. Email Confirmation Not Enforced on Login

**Severity:** Medium

Devise's `confirmable` module is loaded and confirmation emails are sent on registration. However, the login path uses `user.valid_password?(password)` directly — it does not call Devise's `sign_in` which would check `user.active_for_authentication?` (and thus enforce confirmation). A user can log in and use the full app without confirming their email.

**Fix:** In `SessionsController#create`, after `valid_password?` succeeds, add:

```ruby
unless @user.confirmed?
  @error_type = :unconfirmed
  render :new, status: :unprocessable_content
  return
end
```

Or call `@user.active_for_authentication?` before `login(@user)`.

---

#### 2. OmniAuth: Existing Account UID Not Updated on Re-Login

**Severity:** Low

`User.find_or_create_from_oauth` finds existing users by email and calls `assign_attributes` to write the UID, but then only calls `user.save! if user.new_record?`. If the user already exists but has no `google_uid`, the UID is never persisted.

**Fix:**

```ruby
def self.find_or_create_from_oauth(provider, auth)
  find_or_initialize_by(email: auth.info.email.downcase).tap do |user|
    user.assign_attributes(name: auth.info.name, "#{provider}_uid" => auth.uid)
    user.save!   # save both new and existing records
  end
rescue ActiveRecord::RecordInvalid
  user
end
```

Note: `save!` on an existing user changes `updated_at` on every OAuth login — acceptable for this use case.

---

#### 3. OmniAuth: Email Can Be nil for Apple Sign In

**Severity:** Medium

Apple Sign In only returns the user's email on the **first** authorization. On subsequent authorizations, `auth.info.email` will be nil. The current code handles this with a fallback to `auth.extra.raw_info.email`, but Apple does not populate that field on repeat sign-ins either.

**Fix:** Store the `apple_uid` after first login. On subsequent logins, find by `apple_uid` instead of email:

```ruby
def self.find_or_create_from_oauth(provider, auth)
  uid_column = "#{provider}_uid"
  user = find_by(uid_column => auth.uid)
  user ||= find_by(email: auth.info.email&.downcase) if auth.info.email.present?
  user ||= initialize_from_oauth(provider, auth)
  user
end
```

---

#### 4. Debug/Test Routes Exposed in Production

**Severity:** Medium

Routes `/env`, `/model-test`, `/test-load`, `/test`, `/i18n-test`, and `/test-db` are defined in `routes.rb` with no authentication or environment guard. Particularly, `/env` reveals whether `DATABASE_URL`, `RAILS_MASTER_KEY`, and `SECRET_KEY_BASE` are set. While values are not exposed, this leaks operational intelligence.

**Fix:** Wrap in an environment guard:

```ruby
if Rails.env.development? || Rails.env.test?
  get "/env", to: ...
  get "/model-test", to: ...
  # etc.
end
```

---

#### 5. `force_ssl` Disabled

**Severity:** Low (Render-specific, acknowledged)

`config.force_ssl = false` means Rails does not redirect HTTP to HTTPS. Traffic arriving over HTTP to the Render service (if possible) would not be upgraded. Render's edge typically handles this, but it is not enforced at the application layer.

**Fix:** Acceptable given `config.assume_ssl = true` and Render's infrastructure. Document as a known trade-off. When moving to a paid plan with a custom domain, re-enable `force_ssl`.

---

#### 6. CSP in Report-Only Mode

**Severity:** Low

`config.content_security_policy_report_only = true` means the CSP is not enforced — it only reports violations. This is appropriate while the policy is being tuned, but enforcement should be enabled before the app handles sensitive health data at scale.

**Fix:** After verifying no violations in Sentry, change to:

```ruby
config.content_security_policy_report_only = false
```

---

#### 7. No Account Lockout on Brute Force

**Severity:** Low-Medium

The IP-based login rate limit (5 attempts / 15 min) protects against brute force from a single IP. A distributed attack, or a targeted attack against a specific account from multiple IPs, is not mitigated. Devise's `:lockable` module is not configured.

**Fix:** Enable `devise :lockable, lock_strategy: :failed_attempts, maximum_attempts: 10, unlock_strategy: :email` on the User model, with appropriate migration.

---

#### 8. Invite Token Entropy

**Severity:** Low

`invite_token` is stored in the `users` table and indexed, but the generation mechanism is not visible in the reviewed code. If tokens are generated with low entropy (e.g., short random strings), they could be guessable.

**Fix:** Ensure invite tokens are generated with `SecureRandom.urlsafe_base64(32)` or equivalent.

---

#### 9. `update_profile` Email Change — No Password Re-confirmation

**Severity:** Medium

`SettingsController#update_profile` allows changing the user's email with no password confirmation required:

```ruby
if params[:email].present? && params[:email] != @user.email
  @user.update(email: params[:email])
```

While Devise's `reconfirmable: true` means the new email goes to `unconfirmed_email` and requires confirmation, an attacker with an active session (e.g., on a shared device) could change the email address without knowing the current password, then confirm via email.

**Fix:** Require current password for email changes:

```ruby
unless @user.valid_password?(params[:current_password])
  redirect_to profile_settings_path, alert: "Current password required"
  return
end
```

---

### Summary Table

| # | Finding | Severity | Fix Complexity |
|---|---------|----------|----------------|
| 1 | Email confirmation not enforced on login | Medium | Low |
| 2 | OAuth UID not saved for existing users | Low | Low |
| 3 | Apple Sign In: email nil on repeat logins | Medium | Medium |
| 4 | Debug routes exposed in production | Medium | Low |
| 5 | force_ssl disabled | Low | Low (deferred) |
| 6 | CSP in report-only mode | Low | Low |
| 7 | No account lockout | Low-Medium | Medium |
| 8 | Invite token entropy unknown | Low | Low |
| 9 | Email change requires no password confirmation | Medium | Low |

---

*End of documentation.*
