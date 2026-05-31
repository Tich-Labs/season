---
layout: default
---

# Season — Backlog

**Last Updated:** 31 May 2026 (2nd update)

---

## Milestone Overview

| Milestone | Feature | Status |
|-----------|---------|--------|
| **M3** | Tracking & Symptoms (submit screen) | ✅ Built — ⏳ *Submit modal on Superpowers pending* |
| **M4** | Personalized Tips | ✅ Built |
| **M4** | Dietary-aware nutrition filtering | ✅ Built |
| **M4** | Push Notifications | 🏗️ In Progress |
| **M5** | Reminders (ActionMailer) | ✅ Built |
| **M6** | Engagement (Streaks/Flames) | ❌ Not in scope |
| **M7** | Onboarding | ✅ Built |
| **M8** | Paywall (Stripe) | ⏳ Planned |
| **🏗️ Native App** | iOS/Android via Ruby Native | 🏗️ In Progress |
| **🔑 Social Login** | Apple / Google / Facebook | 🔴 Needs credentials + iOS integration |
| **🌐 PWA** | manifest.json, service-worker.js | ✅ Done |
| **📋 GDPR** | Compliance items | 🟡 3 high, 🟢 5 medium |
| **🔒 Security** | Backlog items | ⏳ 5 open |
| **🔧 Devise** | Auth cleanup | 🟡 3 medium |

---

## Active Work Items

### M3 — Tracking & Symptoms

| # | Item | Status |
|---|------|--------|
| 1 | Symptom tracking + period dates | ✅ Built |
| 2 | **Submit review modal on Superpowers page** — Symptoms has a review modal (`submit_modal_controller.js`); Superpowers uses a plain link. Add modal for consistency. | ⏳ Needs team confirmation |

### M4 — Personalized Tips & Push Notifications

| # | Item | Status |
|---|------|--------|
| 1 | Superpower / Nutrition / Sport advice per phase | ✅ Built |
| 2 | **Push Notifications** — Daily 10am weekly feedback nudge, period reminders, etc. | 🏗️ In Progress (next after Ruby Native) |

### M8 — Paywall

| # | Item | Status |
|---|------|--------|
| 1 | Stripe integration for Premium tiers (launch as 100% Free for first month) | ⏳ Planned |

### 🏗️ Native App (iOS/Android)

| # | Item | Status |
|---|------|--------|
| 1 | **Ruby Native** — Interim approach for App Store deployment (pivoted from iOS native + Android scaffold) | 🏗️ In Progress |

### 🔑 Social Login (OmniAuth)

| # | Item | Status |
|---|------|--------|
| 1 | Apple sign-in | 🔴 Needs credentials + iOS WKWebView cookie testing |
| 2 | Google sign-in | 🔴 Needs credentials + iOS WKWebView cookie testing |
| 3 | Facebook sign-in | 🔴 Needs credentials + iOS WKWebView cookie testing |

### 🌐 PWA

| # | Item | Status |
|---|------|--------|
| 1 | manifest.json, service-worker.js, offline support | ✅ Done |

### 📋 GDPR & Privacy

#### 🟡 HIGH (Before Launch)

| # | Item | Ref | Notes |
|---|------|-----|-------|
| 1 | **Data Export** (`GET /account/export`) | Art. 20 | Download all user data as JSON |
| 2 | **Data Retention Policy** | Art. 5(1)(e) | Define periods + auto-deletion job |
| 3 | **Third-Party DPAs** | Art. 28 | DPAs with Render, Resend, Sentry |
| 4 | **Privacy Policy Update** | Art. 13-14 | Add consent mechanism + retention periods |

#### 🟢 MEDIUM (Post-Launch)

| # | Item | Notes |
|---|------|-------|
| 5 | Enable DB Encryption (pgcrypto) | Encrypt sensitive fields |
| 6 | Invite Token Expiry | Tokens expire after 7 days |
| 7 | Audit Logging | Log data access |
| 8 | Rate Limiting | Auth endpoints |
| 9 | Article 22 Review | Automated decisions |

### 🔒 Security Backlog

#### ⏳ Open

| ID | Issue | File | Notes |
|----|-------|------|-------|
| RATE-02 | Login rate limiter keyed on `request.ip` — bypassable via `X-Forwarded-For` | `sessions_controller.rb` | ⏳ Open |
| PROD-04 | Devise password minimum is 6 chars (below NIST 8-char minimum) | `config/initializers/devise.rb` | ⏳ Open |
| DATA-01 | Active Storage on local disk — avatars lost on Render redeploy | `config/environments/production.rb` | ⏳ Open (Cloudflare R2 planned) |
| INFO-03 | Sentry gem installed but no initializer — exceptions silently dropped | — | ⏳ Open |
| INFO-02 | `DebugController` unconditional `allow_unauthenticated_access` | `debug_controller.rb` | ⏳ Open (route-guarded only) |
| LOW | Rate limit `POST /launch-signup` (5 req/IP/hour) | `routes.rb` | 🟢 Low |

#### ✅ Resolved

| ID | Issue | Fixed |
|----|-------|-------|
| PROD-05 | `config.hosts` commented out — DNS rebinding | ✅ 2026-04-28 |
| FWKD-01 | Rails 8.0 defaults instead of 8.1 | ✅ 2026-05-06 |
| AUTH-02 | Devise paranoid mode off — account enumeration | ✅ 2026-05-06 |
| CSP-01 | CSP was report-only | ✅ 2026-04-28 |
| HDR-01 | No Permissions Policy | ✅ 2026-04-28 |

### 🔧 Devise & Authentication Cleanup

| # | Item | Notes |
|---|------|-------|
| 1 | Add `devise_parameter_sanitizer` to ApplicationController | Missing param filter |
| 2 | Resolve `:confirmable` — use or remove | Enabled but always skipped |
| 3 | Add user-level rate limiting | Currently per-IP only |

### 🗺️ Other

| # | Item | Status |
|---|------|--------|
| 1 | Calendar Sync (Google/Outlook/Apple) | ⏳ Planned (post-launch) |
| 2 | M6 Engagement (Streaks/Flames) | ❌ Not in scope |
| 3 | Hetzner/Kamal Migration | ⚪ Post-launch (stay on Render.com) |
| 4 | i18n Infrastructure | ✅ Built |

## ✅ RESOLVED (31 May 2026)

### [FEATURE] Dietary preference filtering for nutrition content
**Status:** ✅ DONE

- Added `dietary_preference` column to `cycle_phase_contents` (default: `""`, not null)
- Updated `CyclePhaseContent.for()` to accept `dietary_preference:` param with fallback to default
- Updated `DailyViewController`, `InformationsController` to pass `current_user.food_preference`
- Refactored `ReminderMailer#morning_summary` to load nutrition from DB (was hardcoded)
- Added dietary variant seeds: 40 total records (8 default + 32 dietary variants across 4 diets × 2 locales)
- Admin CMS updated: dietary_preference dropdown, column in index table, permitted params
- All 166 tests pass

---

## ✅ RESOLVED (28 April 2026)

### [GDPR] Consent system — GDPR Article 9
**Status:** ✅ DONE

- `UserConsent` model with full audit trail (IP, user agent, granted_at, revoked_at).
- `ConsentCheck` concern gates symptom/tracking/superpower screens behind `health_data_processing` consent check.
- `SettingsController#consent` and `#save_consents` — single form grants checked types and revokes unchecked active types.
- `ConsentController` at `/consent` for grant-only onboarding-adjacent flow.
- Schema: `user_consents` table with partial unique index `(user_id, consent_type) WHERE revoked_at IS NULL`.

### [GDPR] Account deletion — GDPR Article 17
**Status:** ✅ DONE

- `AccountController#destroy` at `DELETE /account` purges all user data via `user.destroy!` (dependent: :destroy cascades) and purges Active Storage avatar.
- User is logged out and redirected to root with confirmation.

### [SECURITY] Debug routes in production
**Status:** ✅ DONE

All debug and test routes (`/env`, `/test-db`, `/test-load`, `/test`, `/model-test`, `/i18n-test`, `/test-email-prod`) moved behind `unless Rails.env.production?` guards. None are accessible in production.

### [SECURITY] force_ssl, CSP enforcement, Permissions Policy, host authorization
**Status:** ✅ DONE

- `force_ssl = true` — Rails redirects HTTP → HTTPS and sets HSTS.
- CSP: `content_security_policy_report_only = false` — fully enforced; nonces on script-src.
- `config/initializers/permissions_policy.rb` created — camera, mic, geolocation, payment, USB all `:none`.
- `config.hosts` set to `APP_HOST` + Render wildcard with health-check exclusion.

### [ADMIN] Admin CMS full CRUD for CyclePhaseContent
**Status:** ✅ DONE

`Admin::CyclePhaseContentsController` now supports `new`, `create`, `edit`, `update`, `destroy`. Admins can manage all Informations page content from `/admin/cycle_phase_contents` without Rails console access. Table shows last-updated timestamps.

### [FEATURE] Symptoms: cycle_day, temperature, weight
**Status:** ✅ DONE

`SymptomsController#index` now assigns `@cycle_day`. Temperature and weight fields are included in `symptom_params` and persisted to `symptom_logs`.

### [UI] Informations show pages — Figma redesign
**Status:** ✅ DONE

Phase detail pages rebuilt to match Figma: flat white layout, phase-coloured text, three sections (phase title + hormone note / emotional world / that will do you good) with gray divider lines between them.

### [BUG] JS listener leak in QuickActionsController
**Status:** ✅ DONE

`turbo:load` handler stored as `this._checkModals` and removed in `disconnect()`. Previously the anonymous function could not be unregistered, causing cumulative listeners on each page visit.

### [REFACTOR] User#has_consent? → consent?, has_health_consent? → health_consent?
**Status:** ✅ DONE

Method names simplified. All callsites updated including `ConsentCheck` concern.

---

## ✅ RESOLVED (27 April 2026 — commit 18470ff)

### [REFACTOR] Simplifier pass — CycleCalculatorService, SendPeriodRemindersJob, ReminderMailer, SettingsController, FeedbacksController, locales
**Status:** ✅ DONE

1. **CycleCalculatorService** — Added `next_period_start` method using O(1) arithmetic (replaces while loop). Now the single source of truth for next period start prediction across the codebase.
2. **SendPeriodRemindersJob** — Removed duplicate `predicted_start` private method; now delegates to `CycleCalculatorService#next_period_start`.
3. **ReminderMailer** — Removed dead `@calculator` in `period_reminder`; removed `predicted_period_date` private method (superseded by service); moved all hardcoded email subjects to locale files via `t(".subject")`.
4. **SettingsController** — Extracted `save_single_reminder` private helper (morning and birth_control save actions were near-identical clones); wrapped `save_period_reminder` in `ApplicationRecord.transaction`; removed dead `@user = current_user` in 3 notification show actions.
5. **FeedbacksController** — Replaced inline HTML string with `style=` in turbo_stream error response with `app/views/feedbacks/_error.html.erb` partial (Tailwind brand classes only).
6. **Locales (`en.yml`, `de.yml`)** — Added `reminder_mailer.morning_summary.subject` and `reminder_mailer.period_reminder.subject_period_start/end` keys for full i18n coverage of mailer subjects.

---

### [TESTS] Fix 8 pre-existing test failures — all 166 runs now green
**Status:** ✅ DONE

All controller and integration tests pass. The following bugs were identified and fixed:

1. **`settings/notification_birth_control` — 500 SyntaxError (Ruby 3.4)**
   `CONTRACEPTION_META = {…}` was a constant assigned inside an ERB method body. Ruby 3.4 raises `SyntaxError` for constant assignment inside a method. Renamed to a lowercase local variable `contraception_meta`.

2. **`informations#show` — 500 on invalid phase**
   `redirect_to informations_path unless PHASES.include?(phase)` had no `return`, so execution continued past the redirect and called `.merge` on `nil`. Fixed with `and return`.

3. **`feedbacks#create` — 500 / wrong HTTP response**
   - Form had `data-turbo="false"`, which bypassed Turbo entirely so turbo-stream responses never fired. Removed that attribute.
   - Error path was returning a 302 redirect instead of 422. Fixed to `head :unprocessable_content`.
   - i18n key paths were wrong (`feedbacks.create.*` → `feedback.create.*`).

4. **`RegistrationsController#new` — no redirect for authenticated users**
   Visiting `/registration/new` while already signed in did not redirect. Added `redirect_to user_root_path and return if authenticated?`.

5. **`SuperpowersController#show` — hardcoded IDs not in DB**
   Test used IDs 1 and 5 which don't exist as fixtures. Added `test/fixtures/superpower_logs.yml` with records for the `alice` user. Test updated to reference fixtures by name.

6. **`OnboardingController` — wrong step/params in test**
   Test was PATCHing step 1 with `last_period_start` params, but step 1 expects a `name`. Fixed: test now PATCHes step 10 with `last_period_date`.

7. **`TrackingController` — params shape mismatch**
   Test sent `period_start: date` but `period_update` reads `params.dig(:period, :date)`. Fixed test params to `period: { date: date }`.

---

## ✅ RESOLVED (26 April 2026)

### [SMTP] Configure email delivery provider in production
**Status:** ✅ DONE — Resend configured, domain verified

SMTP configured via Resend with `season.vision` domain. Password reset and confirmation emails working.

---

### [JOB] Create NotifyLaunchSignupsJob
**Status:** ✅ DONE

Background job created and configured with Solid Queue.

---

### [MAILER] Generate LaunchSignupMailer
**Status:** ✅ DONE

Branded email templates for password reset and confirmation working in production.

---

### [MODEL] Add validations to LaunchSignup model
**Status:** ✅ DONE

Validations added: presence, uniqueness, email format.

---

### [ADMIN] Add admin view for LaunchSignup
**Status:** ✅ DONE

`Admin::LaunchSignupsController` built with count, table, and CSV export.
```
