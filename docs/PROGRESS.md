# Season Progress Tracking

**Version:** 1.0 (2026-05-06)  
**Updated:** 2026-05-18 19:00  
**Based on:** Codebase Chapters (ch01_00 - ch10_68)

Update this file as you complete audit items. Check off items to track progress toward 100%.

---

## Chapter 1: Foundation (95% → 100%)

### Completed ✅
- [x] Ruby version defined (3.4.7)
- [x] Rails version current (8.1.3)
- [x] Gemfile organized
- [x] .gitignore configured
- [x] PostgreSQL configured (not SQLite)
- [x] Environment configs present
- [x] Linting configured (Rubocop)
- [x] ERB linting configured

### TODO (5% remaining)
- [ ] CI/CD fully configured (.github/workflows)
- [ ] Ensure `bin/rails s` boots without errors
- [ ] Confirm master key gitignored
- [ ] Verify credentials work (`rails credentials:edit`)

**Target: 100% | Status: 95%**

---

## Chapter 2: Core Features (100%)

### Completed ✅
- [x] Models follow naming conventions
- [x] Controllers follow REST patterns
- [x] Routes properly defined
- [x] Strong parameters used
- [x] Validations in models
- [x] Associations defined
- [x] CRUD for all resources
- [x] Flash messages working
- [x] 28 controllers, 12 models

**Target: 100% | Status: 100% ✅**

---

## Chapter 3: Views & Styling (95% → 100%)

### Completed ✅
- [x] Brand colors in Tailwind config
- [x] Mobile container (max-w-app, 430px)
- [x] No inline styles (except dynamic phase colors)
- [x] Image_tag used (not `<img src>`)
- [x] Asset filenames lowercase with hyphens

### TODO (5% remaining)
- [ ] Burger menu text labels use `t()` (hardcoded English)
- [ ] Onboarding screens use `t()` helpers (known debt)

**Target: 100% | Status: 95%**

---

## Chapter 4: Authentication (90% → 100%)

### Completed ✅
- [x] Authentication concern (`app/controllers/concerns/authentication.rb`)
- [x] Sessions controller (login/logout)
- [x] Registrations controller (sign up)
- [x] Password recovery (Devise)
- [x] OAuth configured (Google, Facebook, Apple)
- [x] Cookie-based sessions (7-day expiry)
- [x] CSRF protection enabled
- [x] Protected routes redirect to login
- [x] Admin auth gated by `User#admin?`

### Completed ✅ (continued)
- [x] **Google OAuth credentials on Render** (`GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`) ✅ 2026-05-08
- [x] **Facebook OAuth credentials on Render** (`FACEBOOK_APP_ID`, `FACEBOOK_APP_SECRET`) ✅ 2026-05-08

### TODO (5% remaining)
- [ ] **MEDIUM: Apple OAuth credentials on Render**
  - Set `APPLE_CLIENT_ID`, `APPLE_TEAM_ID`, `APPLE_KEY_ID`, `APPLE_PRIVATE_KEY`
- [ ] **MEDIUM: Devise `config.paranoid = true`** (prevent account enumeration)
  - Uncomment line 93 in `config/initializers/devise.rb`

**Target: 100% | Status: 95%**

---

## Chapter 5: Mobile / iOS PWA (70% → 100% → 97%)

### Safe Area Insets — Done ✅
- [x] Top app bar — `padding-top: env(safe-area-inset-top)`, `min-height: calc(5rem + ...)`
- [x] Main content — `padding-top: calc(6rem + env(safe-area-inset-top))`
- [x] Update/install banners — `bottom: calc(6rem + env(safe-area-inset-bottom))`
- [x] Quick actions FAB — `bottom: calc(2.5rem + env(safe-area-inset-bottom))`
- [x] Feedback modal — `padding-bottom: calc(8rem + env(safe-area-inset-bottom))`

### Touch Target Minimums — Done ✅
- [x] Hamburger button — `min-w-11 min-h-11` with flex centering
- [x] Settings 3-dot menu — `min-w-11 min-h-11`
- [x] Update banner "Refresh" button — `min-w-11 min-h-11`
- [x] Install banner "Add" + "✕" buttons — `min-w-11 min-h-11`

### Turbo Native Auth Token — Done ✅
- [x] Migration: `native_auth_token` + `native_auth_token_created_at` on users
- [x] `has_secure_token :native_auth_token` + `regenerate_native_auth_token!` on User
- [x] `TurboNativeDetection` concern — detects UA, sets request variant, authenticates via `X-Turbo-Native-Token` header
- [x] Included in `ApplicationController`
- [x] Token regenerated on login for native clients (via `Authentication#login`)
- [x] Meta tag `<meta name="native-auth-token">` injected in layout for authenticated native pages

### Offline Fallback — Done ✅
- [x] `public/offline.html` — branded offline page with retry button + online listener
- [x] SW caches `/offline.html` during install
- [x] Navigation requests fall back to offline page when network fails

### App Icon — Done ✅
- [x] `icon-1024.png` generated from 512×512 icon
- [x] `Contents.json` updated with filename reference

### pod install — Done ✅ (migrated to SPM)
- [x] `HotwireNative` pod doesn't exist on CocoaPods → switched to plain WKWebView
- [x] `SceneDelegate.swift` rewritten without `HotwireNative` dependency
- [x] `project.yml` fixed with correct source paths
- [x] `Podfile` removed (no longer needed)

### launch.html.erb Meta Gaps — Done ✅
- [x] Added `mobile-web-app-capable`
- [x] Added `apple-mobile-web-app-title`
- [x] Added `apple-mobile-web-app-status-bar-style`

### Admin Layouts Mobile Meta — Done ✅
- [x] `admin.html.erb` — added viewport-fit=cover, PWA meta tags, manifest link, theme-color, apple-touch-icon
- [x] `admin_auth.html.erb` — same additions

### PWA Infrastructure — Done ✅
- [x] PWA manifest (`app/views/pwa/manifest.json.erb` — standalone, brand colors, 192/512 icons)
- [x] Service worker (`app/views/pwa/service-worker.js.erb` — static asset caching, cache-busting)
- [x] PWA controller (`app/controllers/pwa_controller.rb`)
- [x] PWA routes (`GET /manifest.json`, `GET /service-worker.js`)
- [x] SW client registration + old SW cleanup
- [x] PWA icons in `public/` (`icon-192.png`, `icon.png`, `favicon.png`)
- [x] Install banner (iOS + Android, `install_controller.js`)
- [x] Update banner (`update_prompt_controller.js`)

### iOS Meta Tags — Done ✅
- [x] `viewport-fit=cover`
- [x] `apple-mobile-web-app-capable`, `apple-mobile-web-app-title`, `apple-mobile-web-app-status-bar-style`
- [x] `mobile-web-app-capable`, `theme-color`, `apple-touch-icon`

### Mobile-First CSS — Done ✅
- [x] `max-w-app` (430px) container, mobile-first layout
- [x] Tailwind config with brand colors
- [x] Fixed top app bar, burger menu, FAB quick actions

### iOS Xcode Project — Done ✅
- [x] `project.yml` (XcodeGen), `AppDelegate.swift`, `SceneDelegate.swift`, `Info.plist`
- [x] `LaunchScreen.storyboard`
- [x] `ios/README.md` — setup guide
- [x] App Store deployment guide (`docs/STORE-DEPLOYMENT.md`)
- [x] Turbo Native audit/roadmap (`docs/ios.md`)
- [x] `SceneDelegate.swift` rewritten — uses plain WKWebView (no external deps)
- [x] `project.yml` — fixed source paths and bundle config
- [x] `Podfile` removed — `HotwireNative` pod doesn't exist

### TODO — PWA Polish
- [x] **Offline fallback page** — `public/offline.html` with retry button
- [x] **Pull-to-refresh** — custom touch-based Stimulus controller with spinner + Turbo.visit
- [ ] **Splash screen** — manifest has no splash config; LaunchScreen is basic label
- [ ] **Momentum scrolling** — `-webkit-overflow-scrolling: touch` not broadly applied

### TODO — iOS Native (Turbo Native)
- [x] **Turbo Native auth token system** — built `TurboNativeDetection` concern, `has_secure_token`, token in login flow, meta tag injection
- [x] **path configuration** — `/configurations/ios_v1.json` with modal/pull-to-refresh rules
- [x] **Tab bar** — 3 tabs (Calendar/Daily/Tracking) via `Tabs.swift` + `HotwireTabBarController.swift`
- [x] **Base URL config** — `SEASON_BASE_URL` in `Info.plist`
- [x] **AppDelegate cleanup** — minimal stub (no WKWebView)
- [ ] **Turbo Native view variants** — no `+turbo_native.erb` templates exist
- [ ] **Turbo Frames** — zero `<turbo-frame>` tags anywhere; needed for native partials

### TODO — iOS UX Quality
- [x] **Safe area insets** — added `env(safe-area-inset-*)` to header, main, banners, FAB, feedback modal
- [x] **Touch target minimums** — hamburger, settings dots, banner CTAs all `min-w-11 min-h-11`
- [x] **Incomplete meta in `launch.html.erb`** — added `apple-mobile-web-app-title`, `apple-mobile-web-app-status-bar-style`, `mobile-web-app-capable`
- [x] **Admin layouts lack mobile meta** — added PWA tags to `admin.html.erb` and `admin_auth.html.erb`
- [ ] **Bottom nav vs burger** — currently uses burger menu + FAB; bottom tab bar may be preferred
- [x] **Push notifications** — cross-platform (iOS/Android/PWA via Web Push API)
  - `webpush` gem added, `PushSubscription` model/table, `PushController` (subscribe/unsubscribe)
  - `push` + `notificationclick` handlers in service worker
  - `PushNotificationService` for sending, integrated with morning reminders job
  - Stimulus controller for browser permission + subscription management
  - Settings toggle wired up, VAPID key support via credentials or env vars
- [x] **Access code (pin)** — set/change/remove in settings, lock screen with digit entry, auto-lock after 5 min inactivity
- [x] **Biometric (Face ID / Touch ID)** — WebAuthn-based (creation + assertion flow)
  - `WebauthnCredential` model/table (credential_id, public_key, sign_count)
  - `WebauthnController` with registration-challenge, register, authentication-challenge, authenticate
  - Stimulus controller calling `navigator.credentials.create/get` with platform authenticator
  - Profile settings toggle (requires pin code); enable/disable with one tap
  - Pin unlock screen shows "Use Face ID / Touch ID" button when credentials exist
- [x] **Pull-to-refresh** — custom touch-based Stimulus controller
  - Touch events detect pull-down; element translates down with elastic resistance
  - "Pull down to refresh" / "Release to refresh" indicator text
  - On release: spinner + Turbo.visit refresh; on cancel: snap back
  - `overscroll-behavior: contain` on main content prevents browser conflicts
- [x] **Haptic feedback** — Stimulus controller wrapping `navigator.vibrate()`
  - Actions: light(10ms), medium(20ms), heavy([30,20,30]), selection(5ms), success/error
  - CSS `:active` opacity reduction for all touch-device buttons as tactile fallback
  - @keyframes ptr-spin animation for refresh spinner

### Account-Level
- [ ] **Apple Developer Account** — not yet created/approved
- [ ] **App Store listing** — not created

**Target: 100% | Status: 97%**

---

## Chapter 6: Advanced Features (85% → 95%)

### Completed ✅
- [x] Background jobs (Solid Queue)
- [x] Job classes (SendMorningRemindersJob, etc.)
- [x] Service objects (CycleCalculatorService)
- [x] Caching strategy (Solid Cache)
- [x] Database indexes on foreign keys
- [x] Calendar events CRUD
- [x] Symptom/superpower tracking
- [x] Streaks calculation

### TODO (15% remaining)
- [ ] **MEDIUM: Active Storage S3/R2** - Switch production from local disk
  - Update `config/storage.yml` for production
  - Set S3/R2 credentials in Render
  - Prevents avatar loss on redeploy

**Target: 95% | Status: 85%**

---

## Chapter 7: API Development (N/A)

### Not Applicable
- Season is a PWA with Hotwire (Turbo + Stimulus)
- No API endpoints needed currently
- If API added later, revisit this chapter

**Status: N/A ✅**

---

## Chapter 8: Integration (70% → 95%)

### Completed ✅
- [x] Payment gateway wired (Stripe gem present)
- [x] Email delivery (Resend adapter)
- [x] Environment variables documented
- [x] Third-party gems configured
- [x] **Google + Facebook OAuth credentials on Render** ✅ 2026-05-08

### TODO (20% remaining)
- [ ] **MEDIUM: Apple OAuth credentials on Render** (see Chapter 4)
- [ ] **MEDIUM: Sentry `SENTRY_DSN` on Render**
  - Set `SENTRY_DSN` in Render dashboard
  - Verify `config/initializers/sentry.rb` is correct
- [ ] Stripe paywall (post-launch)
- [ ] Verify webhooks (if using Stripe)

**Target: 95% | Status: 70%**

---

## Chapter 9: Testing (100%)

### Completed ✅
- [x] Test framework configured (Minitest)
- [x] 76 tests passing
- [x] Model tests (validations, associations)
- [x] Controller tests (responses, redirects)
- [x] Integration tests (user flows)
- [x] Mailer tests present
- [x] Job tests present

**Target: 100% | Status: 100% ✅**

---

## Chapter 10: Production (75% → 100%)

### Completed ✅
- [x] Deployment platform configured (Render)
- [x] Build script present (`bin/render-build.sh`)
- [x] Production database (PostgreSQL on Render)
- [x] Assets precompiled in build
- [x] Error pages customized (404, 500)
- [x] Health check endpoint (`/up`)
- [x] HTTPS enforced

### TODO (15% remaining)
- [x] **HIGH: `config.hosts` uncomment** ✅
  - Set to `APP_HOST`, Render wildcard, season.vision, seasonapp.co
  - Health check excluded
- [x] **HIGH: `config.load_defaults 8.1`** ✅
  - Already set in `application.rb`; removed `new_framework_defaults_8_1.rb`
- [x] **HIGH: Rack::Attack on login endpoints** ✅
  - Throttles: login (10/min), registration (5/min), launch-signup (10/5min), password reset (3/5min), block IP at 40/min
- [x] **HIGH: SSL enforcement** ✅
  - `config.assume_ssl = true`, `config.force_ssl = true`
  - Mailer host set to `APP_HOST` env var with https protocol
- [x] **MEDIUM: CSP enforcement** ✅
  - Enforced: nonces for scripts, `unsafe-inline` for styles (inline style attributes)
  - Google Fonts, Sentry connect-src allowed
- [ ] **MEDIUM: VAPID keys in credentials**
  - Generated keys available; run `rails credentials:edit` to persist

**Target: 100% | Status: 90%**

---

## Overall Progress

| Chapter | Topic | Current | Target | Priority Items |
|---------|--------|---------|--------|-----------------|
| 1 | Foundation | 95% | 100% | CI/CD |
| 2 | Core Features | 100% ✅ | 100% | - |
| 3 | Views & Styling | 95% | 100% | i18n fixes |
| 4 | Authentication | 95% | 100% | Google ✅ ready, Facebook ⚠️ pending, Apple ❌ waiting for Dev Account |
| 5 | Mobile / iOS PWA | 97% | 100% | Push, pin, biometrics, pull-to-refresh, haptic ✅ |
| 6 | Advanced | 85% | 95% | Active Storage S3 |
| 7 | API | N/A | N/A | Not applicable |
| 8 | Integration | 75% | 95% | Google OAuth ✅ ready, Facebook ⚠️ pending, Sentry DSN (medium), Stripe wired (post-launch) |
| 9 | Testing | 100% ✅ | 100% | - |
| 10 | Production | 90% | 100% | config.hosts ✅, Rack::Attack ✅, SSL ✅, CSP ✅, VAPID ⏳, Sentry ⏳ |

### Overall: **80% → 97%** (after HIGH priority fixes)

---

## How to Update Progress

### After Fixing an Item:
1. Check off the item in this file: `- [x] Item description`
2. Update the percentage in `guide.html` (Season section)
3. Re-run audit: `/Users/tichlabs/Documents/onlyCode/season-temp/audit_runner.sh all`
4. Commit changes: `git commit -am "Progress: Fixed [item]"`

### Track Launch Readiness:
```
HIGH Priority (Must fix before launch):
- [ ] OAuth credentials on Render
- [x] config.hosts uncomment
- [x] Rack::Attack on login endpoints
- [x] config.load_defaults 8.1
- [x] SSL enforcement (assume_ssl + force_ssl)

MEDIUM Priority (Fix before launch):
- [ ] Devise paranoid mode
- [x] CSP enforcement
- [ ] Active Storage S3/R2
- [ ] Set VAPID keys in credentials (`rails credentials:edit`)
- [ ] Set SENTRY_DSN env var on Render

LOW Priority (Post-launch):
- [ ] Stripe paywall
- [ ] i18n for burger menu
- [ ] Turbo Native wrapper
- [x] Push notifications
- [x] Biometric auth
- [x] Pull-to-refresh
- [x] Haptic feedback
- [ ] Apple Developer Account / App Store listing
```

---

**Last Updated:** 2026-05-18 19:30
**Next Review:** After remaining TODO items
