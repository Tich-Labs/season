# Season — Backlog

Issues tracked here. Push to GitHub with the commands at the bottom of this file.

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
| 5 | M5 Reminders (ActionMailer): Core background jobs to send email notifications for contraception and period starts. | ⚠️ SMTP pending |
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

## Infrastructure Backlog

### 🔴 Critical

### [SMTP] Configure email delivery provider in production
**Labels:** `infrastructure`, `critical`

SMTP is completely commented out in `config/environments/production.rb`.
All emails (confirmation, launch notification) will silently fail until this is wired up.

**Decision needed:** Which provider to use?
- [Resend](https://resend.com) — modern, developer-friendly, generous free tier (3,000/mo)
- [Postmark](https://postmarkapp.com) — best deliverability, 100 free/mo then paid
- [SendGrid](https://sendgrid.com) — 100/day free forever
- [Brevo](https://brevo.com) — 300/day free forever

Once decided, update `config/environments/production.rb`:
```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  user_name: Rails.application.credentials.dig(:smtp, :user_name),
  password:  Rails.application.credentials.dig(:smtp, :password),
  address:   "smtp.<provider>.com",
  port:      587,
  authentication: :plain,
  enable_starttls_auto: true
}
```
Then add credentials via `rails credentials:edit`.

---

### [JOB] Create NotifyLaunchSignupsJob
**Labels:** `feature`, `critical`

There is no job to send the launch notification email.
This is the entire point of the waitlist — users signed up expecting to be notified.

**Blocked by:** SMTP provider decision + `LaunchSignupMailer` (see below).

Implementation:
- `rails generate job NotifyLaunchSignups`
- Iterates all `LaunchSignup` records
- Sends `LaunchSignupMailer.launch_notification(signup).deliver_later`
- Schedule via Solid Queue when ready

---

## 🟡 High

### [MAILER] Generate LaunchSignupMailer with confirmation + launch-day templates
**Labels:** `feature`, `high`

No mailer exists. Users get a UI confirmation but nothing in their inbox.

**Templates needed:**
 1. `confirmation` — "You're on the list! We'll notify you when we launch."
 2. `launch_notification` — "Season is live! Download here → …"

**Blocked by:** SMTP provider decision.

---

## 🟠 Medium

### [MODEL] Add validations to LaunchSignup model
**Labels:** `quality`, `medium`

`app/models/launch_signup.rb` is completely bare — all validation is in the controller.

Add:
```ruby
validates :email, presence: true,
                  uniqueness: { case_sensitive: false },
                  format: { with: URI::MailTo::EMAIL_REGEXP }
```

---

### [ADMIN] Add admin view for LaunchSignup count + list
**Labels:** `admin`, `medium`

No visibility into how many people have signed up for the waitlist.

- Add `admin/launch_signups_controller.rb` with `index` action
- Simple view: total count + table of emails + signup dates
- Mount under existing admin layout (already has `admin/` namespace)

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

From security audit 2026-04-25. Critical items already fixed. These are the remaining findings.

### 🔴 High

| ID | Issue | File | Fix |
|----|-------|------|-----|
| PROD-05 | `config.hosts` is commented out — DNS rebinding protection disabled | `config/environments/production.rb` | Uncomment and set to `ENV.fetch("APP_HOST")` + health check exclusion |
| RATE-02 | Login rate limiter keyed on `request.ip` — bypassable via `X-Forwarded-For` spoofing | `sessions_controller.rb` | Add `rack-attack` gem + trusted proxy config |
| FWKD-01 | `config.load_defaults 8.0` but app runs Rails 8.1.3 — missing 8.1 security defaults | `config/application.rb` | Run `bin/rails app:update` and review `new_framework_defaults_8_1.rb` |

### 🟠 Medium

| ID | Issue | File | Fix |
|----|-------|------|-----|
| AUTH-02 | Devise paranoid mode off — account enumeration possible via password reset/confirm responses | `config/initializers/devise.rb` | `config.paranoid = true` |
| CSP-01 | CSP is report-only with no `report-uri` — zero enforcement or observability | `config/initializers/content_security_policy.rb` | Add `report-uri` endpoint, then flip `report_only` to `false` |
| HDR-01 | No Permissions Policy — camera, mic, geolocation unrestricted | missing file | Create `config/initializers/permissions_policy.rb` |
| PROD-04 | Devise password minimum is 6 chars (below NIST 8-char minimum) | `config/initializers/devise.rb` | `config.password_length = 10..128` |
| DATA-01 | Active Storage on local disk in production — avatars lost on every Render redeploy | `config/environments/production.rb` | Switch to S3 / Cloudflare R2 |

### 🟢 Info

| ID | Issue | Notes |
|----|-------|-------|
| INFO-03 | Sentry gem installed but no initializer found — exceptions silently dropped in production | Create `config/initializers/sentry.rb` and add `SENTRY_DSN` to `render.yaml` |
| INFO-02 | `DebugController` has unconditional `allow_unauthenticated_access` — relies on route guard only | Add `raise` or environment check inside the controller as belt-and-suspenders |

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
