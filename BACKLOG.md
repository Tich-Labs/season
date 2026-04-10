# Season — Backlog

Issues tracked here. Push to GitHub with the commands at the bottom of this file.

---

## 🔴 Critical

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

### [JOB] Create NotifyLaunchSignupsJob — scheduled for April 14th
**Labels:** `feature`, `critical`

There is no job to send the launch notification email.
This is the entire point of the waitlist — users signed up expecting to be notified on April 14th.

**Blocked by:** SMTP provider decision + `LaunchSignupMailer` (see below).

Implementation:
- `rails generate job NotifyLaunchSignups`
- Iterates all `LaunchSignup` records
- Sends `LaunchSignupMailer.launch_notification(signup).deliver_later`
- Schedule via Solid Queue recurring or one-off: `NotifyLaunchSignupsJob.set(wait_until: Date.new(2026, 4, 14).beginning_of_day).perform_later`

---

## 🟡 High

### [MAILER] Generate LaunchSignupMailer with confirmation + launch-day templates
**Labels:** `feature`, `high`

No mailer exists. Users get a UI confirmation but nothing in their inbox.

**Templates needed:**
1. `confirmation` — "You're on the list! We'll notify you on April 14th."
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
  --title "[JOB] Create NotifyLaunchSignupsJob — scheduled for April 14th" \
  --body "No job exists to send launch notifications. This is the entire point of the waitlist. Blocked by SMTP + LaunchSignupMailer. Needs to be scheduled before April 14th." \
  --label "feature,critical"

# High
gh issue create \
  --title "[MAILER] Generate LaunchSignupMailer with confirmation + launch-day templates" \
  --body "No mailer exists. Users get UI confirmation but nothing in their inbox. Two templates needed: confirmation on signup, and launch notification on April 14th. Blocked by SMTP provider decision." \
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
