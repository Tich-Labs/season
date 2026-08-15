---
layout: default
---

# Season — Security Audit & Fix Report

**Date:** 15 August 2026
**Branch:** `main`
**Rails version:** 8.1.3.1
**Auditor:** `rails-security-auditor` agent (full app scan — config, auth, admin gating, secrets handling, headers)

---

## Summary

| Severity | Found | Fixed | Deferred (needs a decision) |
|----------|:-----:|:-----:|:----------------------------|
| ❌ Critical | 1 | 1 | 0 |
| ⚠️ High | 5 | 4 | 1 |
| 🔶 Medium | 5 | 3 | 0 (2 verified, no fix needed) |
| ℹ️ Info | 4 | 1 | 0 (3 verified/intentional, no fix needed) |
| ✅ Passed | 14 | — | — |

**A new finding surfaced while fixing the Critical one** — see [PIN lock is UI-only, not server-enforced](#new-finding-pin-lock-is-ui-only-not-server-enforced) below. It's not in the counts above since it wasn't part of the original scan.

This is a living document — statuses below are updated as each finding is closed out. See [Fix Log](#fix-log) for the running list of commits.

---

## ❌ Critical

### WebAuthn "authentication" performed no cryptographic verification and bypassed PIN protection
**Status:** ✅ **Fixed**
**Files:** `app/controllers/webauthn_controller.rb`, `app/models/webauthn_credential.rb`, `app/javascript/controllers/webauthn_controller.js`, `Gemfile`

There was no `webauthn` gem in `Gemfile`/`Gemfile.lock` — this was a hand-rolled implementation. `#register` stored whatever `public_key`/`credential_id` the client sent with no attestation verification. `#authenticate` only checked that a `WebauthnCredential` row existed with the submitted `credential_id` — it never verified a signed assertion against the stored public key (no signature check, no `sign_count` replay check — `sign_count` was hardcoded to `0` and never read back).

**What changed:**
- Added the real `webauthn` gem (cedarcode/webauthn-ruby).
- `registration_challenge`/`register` now build real `WebAuthn::Credential` options and verify the browser's attestation (`WebAuthn::RelyingParty#verify_registration`) before a credential row is ever created. The relying party is built per-request from `request.host`/`request.base_url`, matching the app's existing multi-host setup (`APP_HOST` + `*.onrender.com` + localhost in dev) rather than a fixed initializer value.
- `authentication_challenge`/`authenticate` now verify a real signed assertion against the *stored* public key and a monotonically increasing `sign_count` (`verify_authentication`), rejecting forged signatures and replayed/cloned-authenticator assertions.
- `allow_pin_bypass` is now scoped to `authentication_challenge`/`authenticate` only — `register`/`registration_challenge` require a fully unlocked session. (See the new finding below for an important caveat on what this scoping actually enforces today.)
- The JS client (`webauthn_controller.js`) had two real bugs that would have made even a correct server implementation fail: `register()` was sending a client-extracted public key instead of the attestation object the server needs to verify (`attestationObject` + `clientDataJSON`), and neither `register()` nor `authenticate()` sent the `rawId` field the WebAuthn JSON contract requires alongside `id`. Both fixed.
- No DB migration needed — the existing `credential_id`/`public_key`/`sign_count` columns already fit what the real gem produces.

**Verification:** existing tests couldn't meaningfully exercise this (there's no real authenticator in CI), so I wrote a new suite (`test/controllers/webauthn_controller_test.rb`) using the gem's own `WebAuthn::FakeClient` — a real key-pair-backed simulated authenticator, not a stub. It proves, with actual signature math, that:
- a valid registration is accepted and stores a real verified public key
- a registration attestation signed for the *wrong origin* is rejected
- a *replayed/stale* registration challenge is rejected
- a full authenticate flow verifies the signature, advances `sign_count`, and unlocks PIN
- an assertion forged by a **different key pair** claiming an existing credential's id is rejected (this is the exact gap the old code had)
- a **replayed assertion** (`sign_count` not advancing) is rejected
- ownership scoping on `DELETE` still holds (can't delete another user's credential)

10/10 new tests pass, full suite 375/375, rubocop/erb_lint/`npx standard`/brakeman all clean.

**Note:** there's currently no UI anywhere in the app that triggers `register` (only `pin/show.html.erb` has an "authenticate" button, for an *existing* credential) — registering a new credential is only reachable by calling the API directly. Not a security issue, just means there's no way for a user to actually enroll Face ID/Touch ID yet through the UI; flagging in case that's a gap worth closing separately.

---

## ⚠️ High

### 1. `assume_ssl` disabled while Render terminates TLS upstream
**Status:** ✅ **Fixed**
**File:** `config/environments/production.rb`

`config.assume_ssl` was commented out while `config.force_ssl = true` was active. Render terminates TLS at its edge and forwards to the app over plain HTTP — an `assume_ssl`-shaped setup. Git history shows this exact combination caused a redirect-loop incident before; the fix at the time was to disable `force_ssl`, and `assume_ssl` seems to have been left commented out by omission during a later `load_defaults` update rather than intentionally.

```diff
- # config.assume_ssl = true
+ config.assume_ssl = true
```

The likely original root cause (missing `/up` exclusion in `ssl_options`) is already present in the current file, so this should be safe — worth confirming on the next Render deploy.

---

### 2. No authorization gem (Pundit / CanCanCan)
**Status:** ✅ **Fixed (initial rollout)**
**Files:** `Gemfile`, `app/policies/*` (new), `app/controllers/application_controller.rb`, `app/controllers/{calendar_events,symptoms,superpowers,notifications}_controller.rb`

Controller-level scoping was already done correctly by hand everywhere checked (`current_user.calendar_events.find(...)`, etc. — no IDOR found), and admin gating goes through `Admin::BaseController#require_admin`. Added Pundit anyway, since nothing previously *guaranteed* a future controller action wouldn't skip that hand-scoping pattern.

**What changed:**
- Added `pundit`, included `Pundit::Authorization` in `ApplicationController`, with `Pundit::NotAuthorizedError` rescued the same way a missing record is (404, not a raw 500 — avoids leaking whether a resource exists to a user who isn't its owner).
- `ApplicationPolicy` denies by default — a new resource needs an explicit policy before it's accessible.
- `OwnedRecordPolicy` (shared by `CalendarEventPolicy`, `SymptomLogPolicy`, `SuperpowerLogPolicy`, `NotificationPolicy`) allows `show?`/`update?`/`destroy?` only when `record.user_id == user.id`.
- Wired `authorize` into the four controllers the original audit specifically checked for IDOR (calendar events, symptom logs, superpower logs, notifications), with `after_action :verify_authorized` scoped to just those controllers/actions — not app-wide yet.
- Since every lookup was already scoped through `current_user.assoc.find`, `authorize` can never actually deny today — this is deliberate defense-in-depth, not a fix for a live bug. Its value is systematic: a future action that forgets to scope its lookup, but still calls `authorize`, is now caught here instead of leaking another user's data.
- Added cross-user-access tests for all four resources (`test "cannot view another user's ..."`) — three were previously untested for this; only `calendar_events_controller_test.rb` had one.
- Found and fixed an unrelated pre-existing bug while writing the notifications test: `GET /notifications` 500'd on every request (`.page(params[:page]).per(20)` is Kaminari's API; this app uses `pagy`, which was never actually wired up). The view has no pagination controls at all, so replaced it with a plain `.limit(20)`.

**Not yet done:** only 4 of 51 controllers have policies. Rolling Pundit out further (and turning on `verify_authorized` app-wide) is future work — flagging so it isn't mistaken for full coverage.

---

### 3. OmniAuth CSRF monkey-patch let any non-blank token through, not just missing-cookie cases
**Status:** ✅ **Fixed**
**File:** `config/initializers/omniauth.rb`

The patch exists to work around iOS Safari/WKWebView dropping the session cookie on `button_to` OAuth POSTs. As written, it only blocked requests with **no token at all** — a request with a *present but wrong* `authenticity_token` (trivial for any attacker-controlled form to include) was logged as a mismatch and let through anyway, for every platform, not just native iOS.

Narrowed the fallback to native-app requests only (mirroring `RubyNative::NativeDetection#native_app?`'s user-agent check, since `OmniAuth::Strategy#request` is a raw `Rack::Request` and can't reach the controller helper directly). A wrong token from an ordinary browser is now rejected, matching Rails' default behavior — the native WKWebView cookie-loss case is still relaxed as before.

---

### 4. Google OAuth access/refresh tokens stored unencrypted
**Status:** 🟡 **Deferred — blocked on local master key access**
**File:** `app/models/user.rb`, `users.google_access_token` / `users.google_refresh_token`

Unlike typical PII, a refresh token is a live credential — a DB leak lets an attacker call the Google Calendar API as that user indefinitely (until revoked). Fix is `encrypts :google_access_token, :google_refresh_token` on `User`, which requires Active Record Encryption keys to exist in `config/credentials.yml.enc` (`bin/rails db:encryption:init`) plus a migration to backfill existing plaintext values.

**Not applied because:** `config/master.key` is not present in this working environment, so `credentials.yml.enc` can't be decrypted or edited here — adding the encryption keys has to happen on a machine that has the key. You chose to add the key and pick this back up together once it's in place; the `encrypts` declaration + backfill migration haven't been written yet.

---

### 5. `pin` param not covered by `filter_parameters`
**Status:** ✅ **Fixed**
**File:** `config/initializers/filter_parameter_logging.rb`

`PinController#verify` receives `params[:pin]` — the user's lock-screen code — and none of the existing filters (`:passw`, `:otp`, `:secret`, …) matched it. Combined with production `log_level` defaulting to `:info` (see Medium #1), every PIN attempt was being written to production logs in plaintext.

```diff
  Rails.application.config.filter_parameters += [
    :passw, :email, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn, :cvv, :cvc
+   :pin, :api_key, :auth, :authorization, :credit_card
  ]
```

---

## 🔶 Medium

### 1. Production log level defaulted to `:info`, not `:warn`
**Status:** ✅ **Fixed**
**File:** `config/environments/production.rb`

`:info` logs full request parameter dumps (subject to `filter_parameters`). Combined with the PIN gap above, this was writing sensitive data to logs today.

```diff
- config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
+ config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "warn")
```

---

### 2. CSP nonce missing on one inline `<script>`
**Status:** ✅ **Fixed**
**File:** `app/views/settings/calendar.html.erb`

`content_security_policy_nonce_auto = true` is set, and `application.html.erb`/`launch.html.erb` both correctly nonce their inline scripts — this one didn't. In any browser that honors CSP nonces, this script (the settings-saved toast auto-dismiss) was being silently blocked in production. Swept the rest of `app/views` for the same gap — this was the only one.

```diff
- <script>
+ <script nonce="<%= content_security_policy_nonce %>">
```

---

### 3. Rack::Attack had no health-check safelist
**Status:** ✅ **Fixed**
**File:** `config/initializers/rack_attack.rb`

`render.yaml` sets `healthCheckPath: /up`, but nothing exempted it from the IP-wide `Allow2Ban` blocklist rule. Added an explicit safelist so Render's health checker can never contribute to an IP ban.

---

### 4. Rack::Attack had no scanner-path blocklist
**Status:** ✅ **Fixed**
**File:** `config/initializers/rack_attack.rb`

Added a blocklist for common scanner probe paths (`.php`, `.env`, `.git`, `/wp-admin`, `/phpmyadmin`, `/actuator`, etc.) so that noise is rejected by Rack::Attack before reaching the Rails router, and counts fast toward the existing IP ban.

---

### 5. `invite_token` — verify single-use/expiring
**Status:** ✅ **Verified, no fix needed**
**File:** `app/controllers/invites_controller.rb`

Confirmed `invite_token` is checked against `invite_token_expires_at` and cleared to `nil` after use in both the show and accept actions — already single-use and time-boxed as designed. No plaintext-token-in-DB risk beyond what's already accepted for short-lived, single-use invite links.

---

## ℹ️ Informational

### 1. `enqueue_after_transaction_commit` not set
**Status:** ✅ **Fixed (defensive — no live bug found)**
**File:** `config/initializers/active_job.rb` (new)

Checked every `transaction do...end` block (`settings_controller.rb`, `onboarding_controller.rb`, `tracking_controller.rb`) and every model — no job is currently enqueued inside a transaction or an AR callback, so this wasn't an active bug. Set it as the safe forward-looking default anyway:

```ruby
ActiveJob::Base.enqueue_after_transaction_commit = true
```

Note: `config.active_job.enqueue_after_transaction_commit = true` in `application.rb` does **not** work — Rails' own `ActiveJob::Railtie` explicitly excludes that key from the config it propagates to `ActiveJob::Base`. Has to be set directly on the class in an initializer, which is what's here.

### 2. `SameSite=Lax` cookies (not `Strict`)
**Status:** ✅ **Verified intentional, no change**

`Strict` would drop the session cookie on the cross-site top-level GET navigation back from Google/Facebook/Apple OAuth callbacks, breaking login for all three live providers. `Lax` is the correct choice here.

### 3. Security headers (X-Frame-Options, nosniff, Referrer-Policy, X-XSS-Protection)
**Status:** ✅ **Verified, no change needed**

No `config.action_dispatch.default_headers` override exists anywhere in the app — Rails 8.1's framework defaults (`SAMEORIGIN`, `nosniff`, `strict-origin-when-cross-origin`, `X-XSS-Protection: 0`) apply unweakened.

### 4. No `encrypts` on any model besides the OAuth tokens flagged above
**Status:** 🟡 **Flagged for awareness, not applied**

This is a menstrual-health app — symptom logs and cycle data are inherently sensitive. Worth a deliberate call on encryption-at-rest beyond disk/DB-level encryption, even though nothing here is urgent. Same master-key blocker as High #4 applies if pursued.

---

## ✅ Passed (unchanged)

force_ssl enabled · host restrictions (`config.hosts`) · CSRF protection active (Rails 8.1 default, `:exception` mode) · CSP present and enforced (not report-only) · no `unsafe-eval` · session cookies (`httponly`, `secure` in production, 7-day expiry) · rate limiting on all auth endpoints · no IDOR found across any scoped controller · `allow_unauthenticated_access` confined to genuinely public routes · brakeman + bundler-audit both clean · Rails 8.1.3.1 has no known unpatched CVEs · no hardcoded secrets, `master.key` correctly gitignored · Resend webhook signature verification in place.

---

## New finding: PIN lock is UI-only, not server-enforced

Found while implementing the WebAuthn fix, not part of the original scan. **Not fixed — needs your input on whether/how to change it.**

`PinProtection#require_pin_unlock` (run as a `before_action` on every controller) never actually blocks a request. It only sets `@pin_unlock_required = true` and lets the action run to completion:

```ruby
def require_pin_unlock
  return unless authenticated?
  return unless current_user.pin_set?
  return if session[:pin_verified_at] && session[:pin_verified_at] > PIN_TIMEOUT.ago.to_i

  @pin_unlock_required = true
  session[:return_to_after_unlock] = request.fullpath if request.get? || request.head?
end
```

`application.html.erb` then renders a full-screen modal (`pin/_unlock_modal`) *on top of* the page — but the page underneath, including whatever sensitive content it contains, was already fully rendered into the response either way. There's no `redirect_to`, no `render` short-circuit, no `throw :abort` — nothing that actually stops the request.

Two consequences worth knowing about:

1. **For HTML pages**, PIN-lock is a client-side visual gate — the modal covers the screen, but the underlying DOM already has the content in it (viewable via page source or dev tools without ever unlocking). It protects against a casual shoulder-surfing/walk-by scenario, not a determined user with the same browser.
2. **For JSON-only endpoints** (like `WebauthnController`'s actions), it does *nothing at all* — there's no layout, so `@pin_unlock_required` has no view to affect. This means my `allow_pin_bypass only: [...]` scoping change in the WebAuthn fix above is **not actually a functional access boundary today** — it's correct and forward-looking (it'll matter the moment `require_pin_unlock` is ever made to actually enforce), but it doesn't currently stop a PIN-locked session from calling `/webauthn/register` if `require_pin_unlock` alone is what's supposed to be gating it. In practice this is somewhat moot for WebAuthn specifically, since anyone who could reach that endpoint already has a valid session and, per point 1, already has access to everything the PIN screen was covering anyway.

This means the whole app's "PIN lock" feature is, today, a screen-lock convenience layered on top of an already-authenticated session — not a privilege boundary the server enforces. That may well be the intended design (many apps' app-lock features work exactly this way, with the session cookie being the real security boundary and PIN existing only to deter casual access to an unattended unlocked device) — but it's worth confirming that's a deliberate choice, since it wasn't stated anywhere and the UI (a modal that looks like a hard gate) suggests otherwise.

**If you want this hardened**, the real fix is bigger than a config tweak: sensitive content would need to move behind an endpoint that actually checks `session[:pin_verified_at]` server-side and refuses to serve data (not just refuses to show it) when it's stale — e.g. lazy-loading page content via Turbo Frames/fetch once unlocked, rather than rendering it inline behind a CSS overlay. That's an architecture decision, not something to change unasked.

---

## Fix Log

Checks run after every fix in this batch: `rubocop` (0 offenses), `erb_lint` (0 errors), `npx standard` on touched JS (0 errors), full test suite (**375/375 passing**), `brakeman -q` (0 warnings), `bundler-audit` (0 vulnerabilities).

| # | Finding | Files touched |
|---|---------|----------------|
| 1 | `pin` param logged in plaintext | `config/initializers/filter_parameter_logging.rb` |
| 2 | `assume_ssl` disabled | `config/environments/production.rb` |
| 3 | Production log level `:info` | `config/environments/production.rb` |
| 4 | Missing CSP nonce | `app/views/settings/calendar.html.erb` |
| 5 | No health-check safelist | `config/initializers/rack_attack.rb` |
| 6 | No scanner-path blocklist | `config/initializers/rack_attack.rb` |
| 7 | `enqueue_after_transaction_commit` unset | `config/initializers/active_job.rb` (new) |
| 8 | OmniAuth CSRF fallback too broad | `config/initializers/omniauth.rb` |
| 9 | No authorization gem | `Gemfile`, `app/policies/*` (new), `app/controllers/application_controller.rb`, 4 resource controllers + tests |
| 10 | WebAuthn had no real crypto verification | `Gemfile`, `app/controllers/webauthn_controller.rb`, `app/models/webauthn_credential.rb`, `app/javascript/controllers/webauthn_controller.js`, new test suite |
| — | (incidental) `GET /notifications` 500'd on every request | `app/controllers/notifications_controller.rb` |

## Still Open

| Finding | Blocked on |
|---------|------------|
| Google OAuth tokens unencrypted (High) | `config/master.key` not available in this environment — needed to add AR Encryption keys to credentials. You're adding the key; pick back up together once it's in place. |
| No `encrypts` on health-data models (Info) | Same master-key blocker, lower urgency |
| PIN lock doesn't enforce anything server-side (new finding above) | Needs a decision on whether this is intentional, and if not, how big a change to make |
| Pundit only covers 4 of 51 controllers (High, follow-up) | Expand coverage incrementally; not blocked, just not done yet |
