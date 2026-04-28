# Season — Backlog

**Last Updated:** 28 April 2026

---

## Launch Priorities (V2 Migration)

### 🔴 MUST HAVE (Critical for Launch)
Without these, the 150 users cannot migrate or use the app.

| # | Feature | Status |
|---|---------|--------|
| 1 | Personalized Invite Flow: A /invite/:token landing page to capture those 150 users, pre-fill their names, and allow them to set a password. | ✅ Built |
| 2 | The Cycle Engine: A robust CycleCalculatorService that takes "Last Period Date" and "Cycle Length" to determine the 4 phases (Winter, Spring, Summer, Autumn). | ✅ Built |
| 3 | M3 Tracking & Server-Side Storage: Users must be able to log symptoms and period dates. Unlike V1's local storage, this must be encrypted on our PostgreSQL backend. | ✅ Built |
| 4 | M7 Onboarding: A smart, Hotwire-driven multi-step form that collects cycle history and language preference (EN/DE). | ✅ Built |
| 5 | M5 Reminders (ActionMailer): Core background jobs to send email notifications for contraception and period starts. | ✅ Built |
| 6 | i18n Infrastructure: English as the default, with German translations for all UI elements—no hardcoded strings. | ✅ Built |
| 7 | Simple Admin Table: A single /admin view with Ransack to search, filter, and track which of the 150 users have successfully migrated. | ✅ Built |

### 🟡 SHOULD HAVE (High Priority)
Important for user retention, but the app "works" without them.

| # | Feature | Status |
|---|---------|--------|
| 1 | M4 Personalized Tips: Displaying the "Superpower," "Nutrition," and "Sport" advice based on the current phase. | ✅ Built |
| 2 | Social Login (OmniAuth): Sign-in with Apple, Google, and Facebook to reduce friction. | 🔴 Credentials needed |
| 3 | Hotwire Native Wrapper: Deploying the app as a "native" shell on iOS/Android so it's accessible via the App Store. | ⏳ Planned |

### 🟢 COULD HAVE (Nice to Have)
These are your "Intentional Tech Debt" candidates. Cut these first if launch starts looking shaky.

| # | Feature | Status |
|---|---------|--------|
| 1 | M6 Engagement (Streaks/Flames): The gamification system (Flammen) and reward badges. | ❌ Not in scope |
| 2 | M8 Basic Paywall: Stripe integration for Premium tiers. Launch as "100% Free" for the first month. | ⏳ Planned |
| 3 | Calendar Sync: Bi-directional sync with Google/Outlook/Apple. Manual entry is sufficient for MVP. | ⏳ Planned |

### ⚪ WON'T HAVE (Post-Launch)
Deferred to Phase 2 (Global Expansion).

| Feature | Notes |
|---------|-------|
| PWA Layer | Optimization for low-bandwidth/offline African markets |
| Hetzner/Kamal Migration | Staying on Render.com for the launch |
| Push Notifications | Rely on Email Reminders for MVP |

---

## GDPR & Privacy Compliance (28 April 2026 Update)

### ✅ DONE (Ready for EU Launch)

| # | Feature | GDPR Ref | Notes | Status |
|---|---------|---------|-------|--------|
| 1 | **Account Deletion** (`DELETE /account`) | Art. 17 | Full data purge via `AccountController#destroy` | ✅ Done |
| 2 | **Explicit Consent for Health Data** | Art. 9 | `UserConsent` model + audit trail; `/settings/consent` grant/revoke UI; `ConsentCheck` concern enforces gate | ✅ Done |
| 3 | **Privacy Policy** | Art. 13-14 | ⚠️ Needs update to reference consent mechanism and retention periods | ⚠️ Needs update |
| 4 | **Cookie Consent Banner** | ePrivacy | No third-party cookies in use | ✅ N/A |

### 🟡 HIGH (Required Before Launch)

| # | Feature | GDPR Ref | Notes |
|---|---------|---------|-------|
| 5 | **Data Export** (`GET /account/export`) | Art. 20 | Not yet built — user should be able to download all their data as JSON |
| 6 | **Data Retention Policy** | Art. 5(1)(e) | Define retention periods and implement auto-deletion job |
| 7 | **Third-Party DPAs** | Art. 28 | DPAs needed with Render, Resend, Sentry |

### 🟢 MEDIUM (Post-Launch)

| # | Feature | Notes |
|---|---------|-------|
| 8 | Enable DB Encryption (pgcrypto) | Encrypt sensitive fields |
| 9 | Invite Token Expiry | Tokens expire after 7 days |
| 10 | Audit Logging | Log data access |
| 11 | Rate Limiting | Auth endpoints |
| 12 | Article 22 Review | Automated decisions |

### GitHub Issues Template

```bash
# DONE
# 1. Account deletion — DELETE /account ✅ (28 April 2026)
# 2. Explicit consent — /settings/consent ✅ (28 April 2026)

# High - TODO
gh issue create \
  --title "[GDPR] Data Export Endpoint — GDPR Article 20" \
  --body "Implement data portability. GET /account/export returns all user data as JSON (cycle_entries, symptom_logs, superpower_logs, calendar_events, reminders, settings). Include metadata (export date, data categories)." \
  --label "gdpr,high"

gh issue create \
  --title "[GDPR] Data Retention Policy" \
  --body "Define retention periods: cycle data (3 years?), symptom logs (2 years?), calendar events (1 year?). Implement background job to auto-delete expired data. Document in privacy policy." \
  --label "gdpr,high"

gh issue create \
  --title "[GDPR] Privacy Policy Update — GDPR Article 13-14" \
  --body "Update /legal/privacy to include: consent mechanism info, retention periods, DPO contact. See current implementation at /settings/consent." \
  --label "gdpr,high"
```

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

---

## 🟢 Low

### [SECURITY] Rate limit POST /launch-signup endpoint
**Labels:** `security`, `low`

The `POST /launch-signup` endpoint has no rate limiting. Anyone can flood the DB or abuse it.

Options:
- Use `Rack::Attack` (add gem to Gemfile)
- Or throttle in `routes.rb` via middleware

Suggested rule:
```ruby
# config/initializers/rack_attack.rb
Rack::Attack.throttle("launch-signup/ip", limit: 5, period: 1.hour) do |req|
  req.ip if req.path == "/launch-signup" && req.post?
end
```

---

## Security Backlog (Post-MVP)

From security audit 2026-04-25. Items resolved on 2026-04-28 are marked.

### 🔴 High

| ID | Issue | File | Status |
|----|-------|------|--------|
| PROD-05 | `config.hosts` is commented out — DNS rebinding protection disabled | `config/environments/production.rb` | ✅ Fixed 2026-04-28 |
| RATE-02 | Login rate limiter keyed on `request.ip` — bypassable via `X-Forwarded-For` spoofing | `sessions_controller.rb` | ⏳ Open |
| FWKD-01 | `config.load_defaults 8.0` but app runs Rails 8.1.3 — missing 8.1 security defaults | `config/application.rb` | ⏳ Open |

### 🟠 Medium

| ID | Issue | File | Status |
|----|-------|------|--------|
| AUTH-02 | Devise paranoid mode off — account enumeration possible via password reset/confirm responses | `config/initializers/devise.rb` | ⏳ Open |
| CSP-01 | CSP was report-only with no enforcement | `config/initializers/content_security_policy.rb` | ✅ Fixed 2026-04-28 — `report_only = false` |
| HDR-01 | No Permissions Policy | missing file | ✅ Fixed 2026-04-28 — `permissions_policy.rb` created |
| PROD-04 | Devise password minimum is 6 chars (below NIST 8-char minimum) | `config/initializers/devise.rb` | ⏳ Open |
| DATA-01 | Active Storage on local disk in production — avatars lost on every Render redeploy | `config/environments/production.rb` | ⏳ Open |

### 🟢 Info

| ID | Issue | Status |
|----|-------|--------|
| INFO-03 | Sentry gem installed but no initializer found — exceptions silently dropped in production | ⏳ Open |
| INFO-02 | `DebugController` has unconditional `allow_unauthenticated_access` — relies on route guard only | ⏳ Open (debug routes now production-guarded, but controller itself unchanged) |

---

## Pushing these as GitHub Issues

Once you've installed `gh` and authenticated, run:

```bash
# Install gh CLI (if not done)
# macOS: brew install gh
# Ubuntu: sudo apt install gh
# then: gh auth login

# Critical issues
gh issue create \
  --title "[SMTP] Configure email delivery provider in production" \
  --body "SMTP is commented out in production.rb. All emails will silently fail. Needs provider decision (Resend / Postmark / SendGrid / Brevo) then credentials wired into production.rb and Rails credentials." \
  --label "infrastructure,critical"

gh issue create \
  --title "[JOB] Create NotifyLaunchSignupsJob" \
  --body "No job exists to send launch notifications. This is the entire point of the waitlist. Blocked by SMTP + LaunchSignupMailer. Needs to be scheduled when ready." \
  --label "feature,critical"

# High
gh issue create \
  --title "[MAILER] Generate LaunchSignupMailer with confirmation + launch-day templates" \
  --body "No mailer exists. Users get UI confirmation but nothing in their inbox. Two templates needed: confirmation on signup, and launch notification. Blocked by SMTP provider decision." \
  --label "feature,high"

# Medium
gh issue create \
  --title "[MODEL] Add validations to LaunchSignup model" \
  --body "app/models/launch_signup.rb is completely bare. Needs: validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }" \
  --label "quality,medium"

gh issue create \
  --title "[ADMIN] Add admin view for LaunchSignup count + list" \
  --body "No visibility into waitlist signups. Add admin/launch_signups_controller.rb with index action showing count + table of emails and signup dates." \
  --label "admin,medium"

# Low
gh issue create \
  --title "[SECURITY] Rate limit POST /launch-signup endpoint" \
  --body "No rate limiting on the launch signup endpoint. Add Rack::Attack: throttle to 5 requests/IP/hour on POST /launch-signup." \
  --label "security,low"
```
