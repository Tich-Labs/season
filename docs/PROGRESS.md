# Season Progress Tracking

**Version:** 1.1 (2026-06-02)
**Updated:** 2026-06-02
**Based on:** Full codebase audit (ch01_00 - ch10_68)

Update this file as you complete audit items. Check off items to track progress toward 100%.

---

## Chapter 1: Foundation (95% → 98%)

### Completed ✅
- [x] Ruby version defined (3.4.7) — `.ruby-version` + `Gemfile`
- [x] Rails version current (8.1.3) — `Gemfile.lock`
- [x] Gemfile organized — 99 lines, grouped by category with comments
- [x] `.gitignore` configured — DB, env, master.key, node_modules, logs, temp, builds
- [x] PostgreSQL configured — all environments use `adapter: postgresql`; zero SQLite
- [x] Environment configs present — `development.rb`, `production.rb`, `test.rb`, `staging.rb`
- [x] Linting configured (Rubocop) — `.rubocop.yml` + `.rubocop_todo.yml` + 5 plugins
- [x] ERB linting configured — `erb_lint` gem installed + invoked in CI + lefthook
- [x] CI/CD fully configured — `.github/workflows/ci.yml` (7 jobs: linters, ruby, js, lint, security, code_quality, test) + `ios.yml` (build, sign, TestFlight)
- [x] Master key gitignored — `/config/master.key` in `.gitignore`
- [x] Credentials work — `credentials.yml.enc` exists (548 bytes, non-empty)

### TODO (2% remaining)
- [ ] **LOW: Create `.erb-lint.yml` config file** — gem runs with defaults only; need `exclude` patterns and linter-specific rules to suppress known false positives (SVG path data)

**Target: 100% | Status: 98%**

---

## Chapter 2: Core Features (100%)

### Completed ✅
- [x] Models follow naming conventions — 17 domain models, all PascalCase/snake_case
- [x] Controllers follow REST patterns — 43 controllers with standard REST + documented custom actions
- [x] Routes properly defined — `resources`/`resource` with `only:`/`except:` everywhere
- [x] Strong parameters used — all controllers checked use `params.expect` or `params.permit`
- [x] Validations in models — presence, uniqueness, inclusion, numericality, custom validators throughout
- [x] Associations defined — `has_many`/`belongs_to` with `dependent:` options on all models
- [x] CRUD for all resources — 17 models, all have appropriate CRUD; partial CRUD cases are documented design decisions (Feedback is create-only → Trello; Streak is read-only → auto-managed)
- [x] Flash messages working — 6 explicit `flash` calls + redirect `notice:`; user-facing AJAX uses Turbo Streams (correct pattern)
- [x] 17 models, 43 controllers (updated from old count of 12 models, 28 controllers)

**Target: 100% | Status: 100% ✅**

---

## Chapter 3: Views & Styling (85% → 95%)

### Completed ✅
- [x] Brand colors in Tailwind config — `brand.primary: #933a35`, `brand.field: #EDE1D5`, phase colors, etc.
- [x] Mobile container (`max-w-app`, 430px) — 52 instances across all major pages
- [x] `image_tag` used — 64 instances, zero `<img src=`
- [x] Burger menu i18n — all text uses `t("nav.menu.xxx")` with en/de translations ✅ (previously flagged as hardcoded)
- [x] Onboarding screens i18n — steps 1-11 + finish use `t()` helpers ✅

### Recently Completed ✅
- [x] **Appointment form redesign** — category picker modal with 9 icon options (Friends, Dinner, Date, Sports, Medical, Birthday, Work, Coffee, Shopping), `season_modal_controller.js` extended with `selectCategory` action, hidden `category` field synced to form, phase-colored date/time block, 365px-width container (2026-06-01)
- [x] **Calendar phase legend auto-hide** — `auto_hide_controller.js` Stimulus controller hides legend after 50s, resets on each page load ✅
- [x] **Admin help page** — comprehensive `/admin/help` guide documenting all admin sections and features ✅
- [x] **Admin promote/demote** — toggle admin flag on users from index table and user detail page ✅

### TODO (15% → now 5% remaining)
- [ ] **MEDIUM: Inline style cleanup** — `calendar_events/new.html.erb`, `symptoms/show.html.erb`, `superpowers/show.html.erb`, and `shared/_native_top_bar.html.erb` use extensive hardcoded hex colors and inline `style=""` instead of Tailwind utilities
- [ ] **MEDIUM: Asset filename cleanup** — uppercase letters and spaces in `icons/appointment/` (8 files), `icons/tracking-icons/` (30 files), `sexual_intercourse/` (8 files), `vaginal_discharge/` (8 files), `icons/` (2 files), `m3/` (multiple), and `settings/` (1 file). Will fail on production Linux.
- [ ] **LOW: `invite.html.erb` i18n** — has hardcoded English (Welcome back text, placeholder, button)
- [x] **LOW: Burger menu text labels use `t()`** — ✅ done (was previously flagged as TODO)

**Target: 100% | Status: 95%** (unchanged — gains offset by newly discovered asset/inline issues)

---

## Chapter 4: Authentication (95% → 98%)

### Completed ✅
- [x] Authentication concern (`app/controllers/concerns/authentication.rb`) — 7-day cookie, httponly, same_site: :lax
- [x] Sessions controller — login/logout with rate limiting (5 attempts/15min)
- [x] Registrations controller — sign up with duplicate check + Turbo Native skip_confirmation
- [x] Password recovery — Devise passwords controller + 5 error states (already-reset, inbox-full, wrong-email, contact)
- [x] OAuth configured — Google, Facebook, Apple in `devise.rb` + `OmniauthCallbacksController`
- [x] Cookie-based sessions (7-day expiry) — `VALID_SESSION_DAYS = 7`
- [x] CSRF protection — Rails default + OAuth skip + monkey-patch for iOS Safari (omniauth.rb)
- [x] Protected routes redirect to login — `before_action :authenticate_user` on all controllers
- [x] Admin auth gated by `User#admin?` — `Admin::BaseController#require_admin`
- [x] **Google OAuth credentials on Render** ✅
- [x] **Facebook OAuth credentials on Render** ✅
- [x] **Apple OAuth configured** — env vars referenced; blocked by Apple Dev Account
- [x] **iOS OAuth CSRF fix** — `config/initializers/omniauth.rb` monkey-patch (2026-05-28)
- [x] **Onboarding step 10 fix** — submit buttons inside their `<form>` elements (2026-05-28)
- [x] **Turbo Native login form fix** — `local: true` on `sessions/new.html+turbo_native.erb` (2026-06-01)
- [x] **Ruby Native OAuth paths fix** — `/users/auth/...` prefix in `config/ruby_native.yml` (2026-06-01)
- [x] **Devise paranoid mode** — `config.paranoid = true` ✅ (was previously flagged as TODO; verified enabled)

### TODO (2% remaining)
- [ ] **MEDIUM: Apple OAuth credentials on Render** — blocked by Apple Developer Account (not yet created)

**Target: 100% | Status: 98%**

---

## Chapter 5: Mobile / iOS PWA (97% → 93%)

### Completed ✅

#### PWA Infrastructure (8/8)
- [x] PWA manifest — `manifest.json.erb` (standalone, brand colors, 192/512 icons)
- [x] Service worker — `service-worker.js.erb` (install/activate/fetch, push+notificationclick)
- [x] PWA controller — `pwa_controller.rb` (skip CSRF + auth)
- [x] PWA routes — `GET /manifest.json`, `GET /service-worker.js`
- [x] PWA icons — `public/icon-192.png`, `icon.png`, `favicon.png`
- [x] Offline fallback page — `public/offline.html` with retry + online listener
- [x] Install banner — `install_controller.js` (iOS custom hint + Android `beforeinstallprompt`)
- [x] Update banner — `update_prompt_controller.js` (service worker update notification)

#### iOS Meta & Safe Area (4/6)
- [x] `viewport-fit=cover` — in `application.html.erb`, `turbo_native.html.erb`, `launch.html.erb`
- [x] `apple-mobile-web-app-title` — "Season"
- [x] `apple-mobile-web-app-status-bar-style` — `black-translucent` in `application.html.erb`
- [x] Safe area insets — 30 instances (`env(safe-area-inset-*)`) across header, main, modals, banners, FAB
- [x] `mobile-web-app-capable` (Android)
- [x] Touch target 44×44px — 6+ instances of `min-w-11 min-h-11`
- [x] Momentum scrolling — `-webkit-overflow-scrolling: touch` on scroll pickers + onboarding

#### iOS Turbo Native (8/8)
- [x] `TurboNativeDetection` concern — UA detection, variant, auth via `X-Turbo-Native-Token`
- [x] `native_auth_token` on User — `has_secure_token` + `regenerate_native_auth_token!`
- [x] `native_auth_token` migration — `db/migrate/20260518120001_add_native_auth_token_to_users.rb`
- [x] Token in login flow — `authentication.rb:41`
- [x] Meta tag injection — `<meta name="native-auth-token">` in `turbo_native.html.erb`
- [x] Path configuration — `ConfigurationsController#ios_v1` + `/configurations/ios_v1.json`
- [x] `config/ruby_native.yml` — app config + 3 tabs + iOS bundle_id/team_id + OAuth paths
- [x] iOS Xcode project — 10 Swift files, `AppDelegate.swift`, `SceneDelegate.swift`, `Tabs.swift`, etc.
- [x] SceneDelegate merge conflict cleanup — removed stale `import Turbo` markers ✅

#### Push & Biometrics (7/7)
- [x] `PushSubscription` model — validates endpoint, p256dh_key, auth_key
- [x] Push controller — `subscribe`/`unsubscribe` + `vapid_public_key`
- [x] SW push handlers — `push` event shows notification, `notificationclick` opens app
- [x] `PushNotificationService` — `send_to_user` + `send_to_all`
- [x] Settings toggle for push — `push_subscription_controller.js` with permission flow
- [x] Pin code protection — `PinProtection` concern, 5-min auto-lock
- [x] Biometric (WebAuthn) — `WebauthnCredential` model, `WebauthnController`, platform authenticator

#### Other UX (3/4)
- [x] Pull-to-refresh — `pull_to_refresh_controller.js` (touch-based with elastic resistance)
- [x] Haptic feedback — `haptic_controller.js` wrapping `navigator.vibrate()`
- [x] `auto_hide_controller.js` — new Stimulus controller for delayed hiding (used on calendar phase legend) ✅ 2026-06-01

### Recently Added (not in old audit)
- [x] **Testing sheets** — `docs/testing-sheet.html` (PWA, 56 tests, 7 sections) + `docs/testing-sheet-ios.html` (iOS, 35 tests, 6 sections), both interactive with status tracking + CSV export + Trello submission ✅ 2026-06-02
- [x] **Test results → Trello** — `TestResultsController#submit` → `TrelloMailer#test_failure` → email-to-board ✅ 2026-06-02

### TODO (7% remaining)
- [ ] **HIGH: `apple-mobile-web-app-capable` meta tag** — completely missing from all layouts. iOS needs this for standalone/fullscreen mode. Must add to `application.html.erb`, `turbo_native.html.erb`, `launch.html.erb`.
- [ ] **MEDIUM: `apple-mobile-web-app-status-bar-style` missing from `turbo_native.html.erb`** — only `application.html.erb` has it
- [ ] **MEDIUM: Splash screen config** — manifest has no splash/screenshots; LaunchScreen is basic label
- [ ] **MEDIUM: `+turbo_native.erb` view variants** — some exist but not comprehensive; Turbo Frames missing
- [ ] **LOW: Bottom nav vs burger** — burger menu + FAB used; bottom tab bar may be preferred on mobile
- [ ] **LOW: Apple Developer Account** — not yet created/approved
- [ ] **LOW: App Store listing** — not created

**Target: 100% | Status: 93%** (dropped from 97% — newly discovered meta tag gaps)

---

## Chapter 6: Advanced Features (85% → 90%)

### Completed ✅
- [x] Background jobs (Solid Queue) — full schema, puma plugin, dedicated DB, 7 job classes
- [x] Job classes — `SendMorningRemindersJob`, `SendWeeklyFeedbackNudgesJob`, `SendPeriodRemindersJob`, `SendBirthControlRemindersJob`, `DataRetentionJob`, `CleanupExpiredInvitesJob`
- [x] Service objects — `CycleCalculatorService`, `PushNotificationService`, `ApnsPushService`, `AvatarService`, `BleedingService`, `MoodPickerService`
- [x] Caching (Solid Cache) — dedicated DB, `solid_cache_entries` table with proper indexes
- [x] Database indexes — every FK column has at least one index; composite unique indexes on `symptom_logs`, `superpower_logs`, `cycle_entries`, `user_consents`, `streaks`
- [x] Calendar events CRUD — `new`/`create`/`edit`/`update`/`destroy` scoped to `current_user`
- [x] Symptom/superpower tracking — full accordion forms, auto-save via Stimulus, review modal
- [x] Streaks calculation — `Streak` model with `increment_streak!`, milestones, `Streakable` concern
- [x] **Weekly Feedback System (8-week survey)** ✅ 2026-05-28
  - Admin CMS: `/admin/weekly_feedback_questions` — CRUD per week, 3 question types
  - Admin Responses view: `/admin/weekly_feedback_responses` — table + CSV export
  - User modal: `_weekly_feedback_modal.html.erb` + `GET/POST /weekly_feedback`
  - Nudge system: in-app banner + push notification job (daily 10am)
  - Responses forward to Trello via `WeeklyFeedbackMailer`
- [x] **Feedback modal split (3 modals)** ✅ 2026-05-28
  - `_feedback_modal.html.erb` (general), `_support_modal.html.erb` (support + bug), `_weekly_feedback_modal.html.erb` (survey)
  - Separate Stimulus controllers, event names, container IDs

### TODO (10% remaining)
- [ ] **MEDIUM: Active Storage S3/R2** — production uses Disk storage (`config.active_storage.service = :local`); S3 config fully commented out in `storage.yml`. Avatars lost on redeploy.

**Target: 95% | Status: 90%**

---

## Chapter 7: API Development (N/A)

### Not Applicable
- Season is a PWA with Hotwire (Turbo + Stimulus)
- No REST/JSON API needed for core functionality
- `POST /test_results/submit` endpoint added for Trello integration ✅

**Status: N/A ✅**

---

## Chapter 8: Integration (75% → 85%)

### Completed ✅
- [x] Stripe gem installed (`Gemfile:44`)
- [x] Email delivery (Resend) — `config.action_mailer.delivery_method = :resend`
- [x] Environment variables documented — `.env.template`
- [x] Third-party gems configured
- [x] **Google OAuth credentials on Render** ✅
- [x] **Facebook OAuth credentials on Render** ✅
- [x] **Apple OAuth credentials configured** ✅ (blocked by Dev Account)
- [x] **Sentry initializer exists** — `config/initializers/sentry.rb`, conditional on `SENTRY_DSN`

### TODO (15% remaining)
- [ ] **MEDIUM: Set `SENTRY_DSN` on Render** — initializer ready, just needs env var
- [ ] **LOW: Stripe paywall** — gem installed but no subscription UI built (post-launch)
- [ ] **LOW: Verify Stripe webhooks** (if paywall goes live)

**Target: 95% | Status: 85%**

---

## Chapter 9: Testing (100% → 85%)

### Completed ✅
- [x] Test framework configured (Minitest)
- [x] 163 tests passing, 0 failures (audit 2026-06-02)
- [x] Model tests — 4 files (`UserTest`, `SymptomLogTest`, `StreakTest`, `CyclePhaseContentTest`)
- [x] Controller tests — 15 files (all major controllers)
- [x] Mailer tests — `reminder_mailer_test.rb`
- [x] Job tests — 3 files (`SendPeriodRemindersJobTest`, `SendBirthControlRemindersJobTest`, `SendMorningRemindersJobTest`)

### TODO (15% remaining)
- [ ] **MEDIUM: Integration / system tests** — `test/integration/` and `test/system/` directories do not exist. No end-to-end or browser-based tests.
- [ ] **LOW: Increase model test coverage** — only 4 of 17 models have tests

**Target: 100% | Status: 85%** (dropped from 100% — integration tests missing; previously marked complete incorrectly)

---

## Chapter 10: Production (90% → 80%)

### Completed ✅
- [x] Deployment platform configured (Render)
- [x] Build script — `bin/render-build.sh` (bundle, tailwind, precompile, seed, solid cache/queue/cable migrate)
- [x] Production database (PostgreSQL on Render) — multi-DB: primary, cache, queue, cable
- [x] Assets precompiled — `precompile` + `clean` in build script; 1-year cache headers
- [x] Error pages — `public/404.html`, `public/500.html`
- [x] Health check endpoint — `GET /up` via `rails/health#show`
- [x] `config.load_defaults 8.1` — `application.rb:12`
- [x] Rack::Attack on login — throttles (login 10/min, registration 5/min, launch 10/5min, password 3/5min), block IP at 40/min
- [x] CSP enforcement — full policy, nonces, `report_only = false`
- [x] VAPID keys — env var support (`VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`), used in `PushSubscription`

### TODO (20% remaining — CRITICAL)
- [ ] **HIGH: `config.hosts` is COMMENTED OUT** — `production.rb:74-80` all commented. No DNS rebinding protection. Previously marked ✅ in PROGRESS.md but IT IS NOT FIXED.
- [ ] **HIGH: SSL enforcement is COMMENTED OUT** — `config.force_ssl = true` commented out in `production.rb:31`. `config.assume_ssl` also commented. Relies on Render TLS termination only; no HSTS. Previously marked ✅ but IT IS NOT FIXED.
- [ ] **MEDIUM: VAPID keys in credentials** — env vars work; `rails credentials:edit` to persist

**Target: 100% | Status: 80%** (dropped from 90% — config.hosts and force_ssl were incorrectly marked as complete)

---

## Overall Progress

| Chapter | Topic | Old | New | Key Issues |
|---------|--------|-----|-----|------------|
| 1 | Foundation | 95% | **98%** | CI/CD done; missing `.erb-lint.yml` |
| 2 | Core Features | 100% ✅ | **100%** ✅ | - |
| 3 | Views & Styling | 95% | **95%** | Inline styles + asset filenames need cleanup; burger i18n fixed |
| 4 | Authentication | 95% | **98%** | Devise paranoid done; Apple OAuth blocked by Dev Account |
| 5 | Mobile / iOS PWA | 97% | **93%** | `apple-mobile-web-app-capable` missing; splash config missing |
| 6 | Advanced Features | 85% | **90%** | Active Storage S3/R2 still needed |
| 7 | API | N/A | N/A | - |
| 8 | Integration | 75% | **85%** | Stripe paywall not built; Sentry DSN pending |
| 9 | Testing | 100% ✅ | **85%** | Integration tests missing; model coverage low |
| 10 | Production | 90% | **80%** | ⚠️ `config.hosts` + `force_ssl` COMMENTED OUT (marked done incorrectly) |

### Overall: **91% → 92%** (gains in Auth/Foundation offset by corrected Production + Testing)

---

## Critical Pre-Launch Items (HIGH Priority)

```
HIGH Priority (Must fix before launch):
- [ ] **config.hosts uncomment** — production.rb:74-80 is all commented. Set to APP_HOST, Render wildcard, season.vision, seasonapp.co
- [ ] **SSL enforcement** — uncomment config.force_ssl = true + config.assume_ssl in production.rb
- [ ] **apple-mobile-web-app-capable meta tag** — add to all 3 layouts (iOS standalone mode broken without it)
- [x] OAuth credentials on Render (Google ✅, Facebook ✅, Apple pending Dev Account)
- [x] Rack::Attack on login endpoints
- [x] config.load_defaults 8.1

MEDIUM Priority (Fix before launch):
- [ ] Active Storage S3/R2 — switch production from local disk storage
- [ ] Set SENTRY_DSN env var on Render
- [ ] Asset filename cleanup — uppercase + spaces in 6 directories (will fail on Linux production)
- [ ] Create .erb-lint.yml config file
- [ ] Inline style cleanup — calendar_events/new, symptoms/show, superpowers/show, _native_top_bar

LOW Priority (Post-launch):
- [ ] Stripe paywall
- [ ] Integration / system tests
- [ ] Turbo Native view variants
- [ ] Splash screen config
- [ ] Apple Developer Account / App Store listing
- [ ] invite.html.erb i18n
```

---

## New Features Since Last Audit (2026-05-28 → 2026-06-02)

| Feature | Date | Details |
|---------|------|---------|
| Appointment form redesign | 2026-06-01 | Category picker modal with 9 icons, phase-colored date block, 365px container |
| Calendar phase legend auto-hide | 2026-06-01 | `auto_hide_controller.js` — hides legend after 50s |
| Admin promote/demote users | 2026-06-01 | Toggle admin flag from users index + user detail page |
| Admin Help page | 2026-06-01 | `/admin/help` — comprehensive guide for all admin sections |
| Testing sheets (PWA + iOS) | 2026-06-02 | `testing-sheet.html` (56 tests) + `testing-sheet-ios.html` (35 tests) |
| Test results → Trello | 2026-06-02 | `TestResultsController#submit` → `TrelloMailer#test_failure` |
| Devise paranoid mode | 2026-06-02 | `config.paranoid = true` verified enabled |
| Turbo Native login `local: true` | 2026-06-01 | Cookie/CSRF fix for iOS WKWebView |
| Ruby Native OAuth path fixes | 2026-06-01 | `/users/auth/...` prefix in config |
| SceneDelegate merge cleanup | 2026-06-01 | Removed stale conflict markers |
| iOS bundle_id update | 2026-06-01 | `com.onrender.seasonv2.rubynative` |

---

**Last Updated:** 2026-06-02
**Next Review:** After fixing HIGH priority production config items

