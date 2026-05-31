# iOS Hotwire Native Wrapper — Implementation Status

## Executive Summary

The Season app has an **iOS wrapper** built with **Hotwire Native** (hotwire-native-ios SPM). The web app handles all content — the wrapper provides a native tab bar (Calendar / Tracking / Settings), path configuration for modal presentation, and token-based auth persistence. The web app's burger menu and FAB are hidden in native context, replaced by the native tab bar.

**Completed:**
- ✅ Hotwire Native tab bar — Calendar, Tracking, Settings
- ✅ Path configuration (`/configurations/ios_v1.json`) — modal rules, tab bar hidden on auth screens
- ✅ Token-based auth (TurboNativeDetection + X-Turbo-Native-Token)
- ✅ CI workflow: archive → manual codesign → zip IPA → altool upload
- ✅ Distribution cert + provisioning profile for headless CI signing
- ✅ 9 GitHub secrets documented
- ✅ Pre-push hook (rubocop + erb_lint + standard)
- ✅ 32 Playwright E2E smoke tests
- ✅ Safe area insets on all key elements (header, content, banners, FAB)
- ✅ Touch target minimums (44pt on interactive elements)
- ✅ Offline fallback page (`/offline.html`)
- ✅ App icon (all sizes in asset catalog)
- ✅ iOS meta tags on all layouts (incl. admin)
- ✅ Hotwire Native project (hotwire-native-ios SPM)
- ✅ PrivacyInfo.xcprivacy (App Store compliance)
- ✅ Scene manifest in Info.plist
- ✅ CI workflow (GitHub Actions: xcodegen → archive → sign → upload)
- ✅ Push notifications (Web Push API)
- ✅ Pin lock screen + biometrics (WebAuthn)

---

## Current Tech Stack Analysis

### What's Already in Place ✅

| Component | Status | Notes |
|-----------|--------|-------|
| **Rails 8.1.3** | ✅ Ready | Modern Rails with Hotwire built-in |
| **Turbo Rails** | ✅ Installed | v2.0.23, fully integrated |
| **Stimulus** | ✅ Active | 17 controllers |
| **Import Maps** | ✅ Configured | No Node/build dependencies |
| **Mobile-First CSS** | ✅ Excellent | Tailwind, max-w-[430px] container |
| **PWA Infrastructure** | ✅ Present | Manifest, service worker, offline page, meta tags |
| **Cookie Auth** | ✅ Web | Cookie-based for regular browser users |
| **Native Auth Token** | ✅ Built | `has_secure_token` on User, `TurboNativeDetection` concern, `X-Turbo-Native-Token` header flow |
| **Safe Area Insets** | ✅ Done | `env(safe-area-inset-*)` on header, content, banners, FAB, feedback modal |
| **Touch Targets** | ✅ Done | `min-w-11 min-h-11` on all interactive elements |
| **iOS Project** | ✅ Hotwire Native | hotwire-native-ios SPM, BridgeComponents, 8 Swift files |
| **Calendar Preferences** | ✅ Complete | 5 toggles: appointments, cycle days, moon phases, holidays, week numbers |

### Key Files
- `Gemfile` (lines 15-16: turbo-rails, stimulus-rails)
- `config/importmap.rb` (Turbo + Stimulus pinned)
- `app/javascript/application.js` (imports Turbo and controllers)
- `app/controllers/concerns/turbo_native_detection.rb` (native token auth)
- `app/views/pwa/service-worker.js.erb` (offline page caching)
- `public/offline.html` (branded offline fallback)

---

## Hotwire/Turbo Current State

### Turbo Integration
```ruby
# Gemfile
gem "turbo-rails"  # Line 15
gem "stimulus-rails" # Line 16
```

**Current Usage:**
- **Turbo Drive:** Active (default for all links/forms)
- **Turbo Streams:** NOT used (no `.turbo_stream.erb` files exist)
- **Turbo Frames:** NOT currently used (none found in views)
- **Stimulus Controllers:** 25 controllers in `app/javascript/controllers/`

**Stimulus Controllers Available (26 active):**
1. `menu_controller.js` - Burger menu (open/close/slider)
2. `quick_actions_controller.js` - Modal management
3. `calendar_index_controller.js` - Calendar dropdown toggle
4. `calendar_toggle_controller.js` - Calendar view switching
5. `symptom_controller.js` - Symptom logging
6. `date_picker_controller.js` - Date selection
7. `feedback_modal_controller.js` - Feedback form modal
8. `open_feedback_controller.js` - Feedback triggers
9. `loader_controller.js` - Loading states
10. `launch_signup_controller.js` - Waitlist signup
11. `install_controller.js` - PWA installation (iOS/Android)
12. `password_visibility_controller.js` - Password toggle
13. `countdown_controller.js` - Launch countdown
14. `feature_slides_controller.js` - Feature carousel
15. `update_prompt_controller.js` - PWA update prompts
16. `coming_soon_controller.js` - Coming soon features
17. `hello_controller.js` - Sample controller
18. `profile_modal_controller.js` - Profile editing modal
19. `haptic_controller.js` - Haptic feedback (`navigator.vibrate()`)
20. `pull_to_refresh_controller.js` - Touch-based pull-to-refresh
21. `push_subscription_controller.js` - Web Push subscription flow
22. `webauthn_controller.js` - Biometric auth (Face ID / Touch ID)
23. `pin_entry_controller.js` - Access code lock screen

---

## Authentication System — Built ✅

### Web Auth (Cookie-based)
```ruby
# app/controllers/concerns/authentication.rb
def login(user)
  reset_session
  session[:user_id] = user.id
  cookies.encrypted[:user_id] = {
    value: user.id,
    expires: VALID_SESSION_DAYS.days.from_now,
    httponly: true,
    secure: Rails.env.production?,
    same_site: :lax
  }
  user.regenerate_native_auth_token! if turbo_native_app?
  Current.user = user
end
```

### Native Auth (Token-based — Meta Tag + X-Turbo-Native-Token header)
```ruby
# app/models/user.rb
has_secure_token :native_auth_token

def valid_native_auth_token?
  native_auth_token.present?
end

def regenerate_native_auth_token!
  regenerate_native_auth_token
  save!
  native_auth_token
end
```

```ruby
# app/controllers/concerns/turbo_native_detection.rb
module TurboNativeDetection
  extend ActiveSupport::Concern

  included do
    before_action :detect_turbo_native
    helper_method :turbo_native_app?
  end

  private

  def detect_turbo_native
    return unless turbo_native_app?

    request.variant = :turbo_native
    authenticate_native_token if request.headers["X-Turbo-Native-Token"].present?
  end

  def _layout
    if turbo_native_app? && lookup_context.exists?("turbo_native", "layouts")
      "turbo_native"
    else
      super
    end
  end

  def authenticate_native_token
    token = request.headers["X-Turbo-Native-Token"] || cookies[:native_auth_token]
    user = User.find_by(native_auth_token: token)
    Current.user ||= user if user&.valid_native_auth_token?
  end

  def turbo_native_app?
    request.headers["HTTP_X_HOTWIRE_NATIVE"].present? || request.user_agent&.include?("Turbo Native")
  end
end
```

### Login Flow for Native Apps
On login, `Authentication#login` calls `user.regenerate_native_auth_token!` when `turbo_native_app?` is true. The token is injected into the `turbo_native` layout via a `<meta name="native-auth-token">` tag and a `<div data-bridge--native-auth-token>` element:

```erb
<% if turbo_native_app? && authenticated? %>
  <meta name="native-auth-token" content="<%= current_user.native_auth_token %>">
  <div data-bridge--native-auth-token data-token="<%= current_user.native_auth_token %>" style="display:none"></div>
<% end %>
```

The iOS `NativeAuthTokenComponent` listens for the `connect` event on the bridge and saves the token to the iOS Keychain via `KeychainHelper`. On subsequent requests, the iOS app sends the token as the `X-Turbo-Native-Token` header, and the server authenticates via `authenticate_native_token`.

### OAuth CSRF Workaround (iOS Safari)
iOS Safari / WKWebView frequently doesn't send session cookies with `button_to` form POSTs, causing `valid_authenticity_token?` to return `false`. This is worked around in `config/initializers/omniauth.rb` by monkey-patching `OmniAuth::Strategy#verified_request?` to return `true` on both exception (Rails 8.1 compat) and `false` return (iOS cookie loss). The OAuth `state` parameter provides independent CSRF protection for the callback.
```ruby
# config/initializers/omniauth.rb
OmniAuth::Strategy.class_eval do
  def verified_request?
    return true unless request.post? || request.put? || request.patch? || request.delete?
    return true unless respond_to?(:protect_against_forgery?) && protect_against_forgery?
    token = request.params["authenticity_token"] || request.env["HTTP_X_CSRF_TOKEN"]
    return false if token.blank?
    begin
      valid_authenticity_token?(session, token) || begin
        Rails.logger.warn "[OmniAuth CSRF] Token mismatch. Allowing (OAuth state provides CSRF)."
        true
      end
    rescue => e
      Rails.logger.error "[OmniAuth CSRF] valid_authenticity_token? raised: #{e.message}. Allowing."
      true
    end
  end
end
```

---

## Layout Structure Analysis

### Mobile-First Design ✅
```erb
<body class="bg-[#FCF9F7] font-['Montserrat'] antialiased h-full overflow-x-hidden">
  <main class="w-full flex-1" style="padding-top: calc(6rem + env(safe-area-inset-top, 0px));">
    <div class="max-w-md mx-auto h-full">
      <%= yield %>
    </div>
  </main>
</body>
```

### Key Observations:
1. **Already constrained to mobile viewport** - `max-w-md` (approx 430px-480px)
2. **Safe area insets applied** — header, main content, banners, FAB, feedback modal all use `env(safe-area-inset-*)` with 0px fallback
3. **Touch targets ≥44pt** — hamburger, settings dots, banner CTAs all have `min-w-11 min-h-11`
4. **Meta tags present:**
   - `mobile-web-app-capable`
   - `apple-mobile-web-app-capable` (all layouts)
   - `apple-mobile-web-app-title`
   - `apple-mobile-web-app-status-bar-style="black-translucent"`
   - Viewport meta with `viewport-fit=cover`
   - `theme-color="#933a35"`
   - `apple-touch-icon`
5. **Top App Bar** — Fixed position header with hamburger menu
6. **No Turbo Native specific layout** — Would need a variant or conditional rendering

---

## Response Formats

| Format | Usage | Turbo Native Compatibility |
|--------|-------|---------------------------|
| HTML | Primary | ✅ Native support via Turbo |
| Turbo Stream | None | ❌ Not yet used |
| JSON | SessionsController (native login) | ✅ Returns auth token + user data |
| Turbo Frame | None | ❌ Should add for native-specific partials |

---

## Navigation Structure

### Key Routes for Native:
```
Authentication: /session/new, /session (POST), /registration/new
Onboarding: /onboarding/:id (steps 1-11), /onboarding/finish
Main App: /calendar, /daily/:date, /tracking, /symptoms, /superpowers
Settings: /settings/edit, /settings/notifications, etc.
```

### Navigation Concerns:
1. **No native-specific routes** - Turbo Native handles navigation automatically
2. **Native top bar** — Uses `native_top_bar_controller.js` with 3-dot overflow menu (Schedule Overview, Day/Weekly/Monthly views, Settings, Logout)
3. **No burger menu on iOS** — hamburger menus are a deprecated anti-pattern. Tab bar + overflow dropdown replaces it.
4. **No deep linking support** - Turbo Native URLs need proper handling

---

## Existing iOS/Mobile Code


### iOS Bridge Components (Swift)

| Component | File | Purpose |
|-----------|------|---------|
| `NativeAuthTokenComponent` | `ios/SeasonApp/SeasonApp/Components/NativeAuthTokenComponent.swift` | Receives auth token from meta tag, stores in Keychain |
| `NotificationTokenComponent` | `ios/SeasonApp/SeasonApp/Components/NotificationTokenComponent.swift` | Handles push notification registration token |
| `KeychainHelper` | `ios/SeasonApp/SeasonApp/Models/KeychainHelper.swift` | iOS Keychain read/write/delete (encrypted storage) |
| `NotificationRouter` | `ios/SeasonApp/SeasonApp/Models/NotificationRouter.swift` | Routes push notification taps to correct tab/screen |
| `NotificationTokenViewModel` | `ios/SeasonApp/SeasonApp/ViewModels/NotificationTokenViewModel.swift` | View model for notification token management |

All bridge components are registered in `AppDelegate.swift`:
```swift
Hotwire.registerBridgeComponents([
    ButtonComponent.self,
    NotificationTokenComponent.self,
    NativeAuthTokenComponent.self
])
```

### PWA Install Controller (`install_controller.js`):
```javascript
this._isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream
```

### iOS Meta Tags (all layouts):
- `apple-mobile-web-app-capable`
- `apple-mobile-web-app-title="Season"`
- `apple-mobile-web-app-status-bar-style="black-translucent"`
- `mobile-web-app-capable`
- `apple-touch-icon` links
- `theme-color="#933a35"`
- `viewport-fit=cover`

### Offline Support:
- `public/offline.html` — branded offline page with retry button + auto-reload on reconnect
- Service worker caches `/offline.html` during install
- Navigation requests fall back to offline page when network fails
- Static assets use cache-first strategy with network fallback

---

## Remaining Gaps

### A. Native-Specific Views (3-5 days)

Create Turbo Native specific view variants:
```
app/views/calendar/index.html+turbo_native.erb
app/views/sessions/new.html+turbo_native.erb
app/views/onboarding/show.html+turbo_native.erb
```

Or use Turbo Frames to wrap content:
```erb
<%= turbo_frame_tag "main_content" do %>
  <!-- Existing content -->
<% end %>
```

### B. Turbo Frames (2-3 days)

Wrap key content areas in `<turbo-frame>` tags to enable native-specific partial replacements. Currently zero turbo frames exist.

### C. iOS Navigation Bridging (3-5 days)

Turbo Native needs to handle:
1. **Modal presentations** - Some screens should present as modals
2. **Custom transitions** - Native feel for certain navigations
3. **Pull-to-refresh** - Native refresh control
4. **Haptic feedback** - For interactions

```swift
// Configure path-specific behavior
session.pathConfiguration = PathConfiguration(sources: [
    .init(url: URL(string: "https://season.vision/turbo_native_config.json")!)
])

// turbo_native_config.json
{
  "rules": [
    {
      "patterns": ["/calendar", "/daily/*"],
      "properties": {
        "presentation": "default"
      }
    },
    {
      "patterns": ["/settings/*"],
      "properties": {
        "presentation": "modal"
      }
    }
  ]
}
```

### D. Push Notifications
- Implemented via Web Push API (cross-platform, works on iOS 16.4+)
- `webpush` gem, `PushSubscription` model, `PushController` (subscribe/unsubscribe)
- Stimulus controller for browser permission flow
- PushNotificationService integrated with SendMorningRemindersJob

### E. Biometric (Face ID / Touch ID)
- Implemented via WebAuthn browser API (works on iOS 14.5+)
- `WebauthnCredential` model, `WebauthnController` (registration + authentication)
- Platform authenticator with `userVerification: "required"`
- Pin unlock screen shows "Use Face ID / Touch ID" button
- Profile settings toggle to enable/disable

### F. App Store Compliance
- **No `PrivacyInfo.xcprivacy` file** — mandatory for all App Store submissions since Spring 2024 (blocker)
- No `ITSAppUsesNonExemptEncryption` in Info.plist
- No privacy usage descriptions (not needed currently, but HealthKit would require them)
- `Package.resolved` not committed — SPM dependency versions not tracked in git

### G. Splash Screen
- Manifest has no splash config; LaunchScreen is basic centered label

### G. Momentum Scrolling
- `-webkit-overflow-scrolling: touch` not broadly applied to scrollable containers

### H. Pull-to-Refresh
- Implemented via custom Stimulus controller with touch events
- Elastic resistance, indicator text, spinner on release, Turbo.visit refresh
- `overscroll-behavior: contain` on main content

### I. Haptic Feedback
- Implemented via Stimulus controller wrapping `navigator.vibrate()`
- Actions: light/medium/heavy/selection/success/error
- CSS `:active` opacity reduction on touch devices as tactile fallback

---

## Files Created/Modified

### New Files:
```
1. app/controllers/concerns/turbo_native_detection.rb  — Token auth for native
2. app/controllers/configurations_controller.rb        — iOS path rules endpoint
3. app/views/layouts/turbo_native.html.erb             — Turbo Native layout with meta tag auth bridge
4. app/views/shared/_native_top_bar.html.erb           — 3-dot overflow dropdown menu
5. db/migrate/20260518120000_add_native_auth_token_to_users.rb
6. public/offline.html                                 — Branded offline page
7. ios/SeasonApp/SeasonApp/SceneDelegate.swift         — Navigator + tab bar setup
8. ios/SeasonApp/SeasonApp/AppDelegate.swift           — Bridge component registration
9. ios/SeasonApp/SeasonApp/Tabs.swift                  — Tab definitions (Calendar/Tracking/Settings)
10. ios/SeasonApp/SeasonApp/path-configuration.json    — Bundled path rules
11. ios/SeasonApp/SeasonApp/Components/NativeAuthTokenComponent.swift  — Token → Keychain bridge
12. ios/SeasonApp/SeasonApp/Components/NotificationTokenComponent.swift — Push token registration bridge
13. ios/SeasonApp/SeasonApp/Models/KeychainHelper.swift               — Encrypted Keychain storage
14. ios/SeasonApp/SeasonApp/Models/NotificationRouter.swift           — Push notification routing
15. ios/SeasonApp/SeasonApp/ViewModels/NotificationTokenViewModel.swift — Token management VM
16. ios/SeasonApp/project.yml                                          — XcodeGen project spec
```

### Modified Files:
```
1. app/models/user.rb                    — has_secure_token + valid_native_auth_token?
2. app/controllers/application_controller.rb     — Include TurboNativeDetection
3. app/controllers/sessions_controller.rb        — regenerate_native_auth_token! on login
4. app/controllers/configurations_controller.rb  — ios_v1 + android_v1 JSON endpoints
5. app/controllers/pwa_controller.rb             — Skip auth for offline/manifest
6. app/views/layouts/application.html.erb        — Safe area insets + touch targets
7. app/views/layouts/launch.html.erb             — Missing iOS meta tags
8. app/views/layouts/admin.html.erb              — iOS/PWA meta tags
9. app/views/layouts/admin_auth.html.erb         — iOS/PWA meta tags
10. app/views/shared/_quick_actions.html.erb     — Safe area bottom on FAB
11. app/views/shared/_feedback_modal.html.erb    — Safe area bottom padding
12. app/views/pwa/service-worker.js.erb          — Offline page caching
13. db/schema.rb                                 — native_auth_token columns
14. ios/SeasonApp/SeasonApp/Info.plist           — Scene manifest, privacy, encryption
15. ios/SeasonApp/SeasonApp/Assets.xcassets/AppIcon.appiconset/ — All icon sizes
16. ios/SeasonApp/SeasonApp/PrivacyInfo.xcprivacy  — App Store compliance manifest
```

---

## Architectural Recommendations (Remaining)

### 1. Use Turbo Frames for Native-Specific Content
```erb
<%= turbo_frame_tag "season_main", data: { turbo_native_target: "main" } do %>
  <!-- Your existing content -->
<% end %>
```

### 2. Add Native Detection at the Layout Level
```erb
<%# app/views/layouts/application.html.erb %>
<% if turbo_native_app? %>
  <%= render "layouts/native_chrome" %>
<% else %>
  <%= render "layouts/web_chrome" %>
<% end %>
```

### 3. Leverage Stimulus for Native-Specific Behavior
```javascript
// app/javascript/controllers/native_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (this.isTurboNative()) {
      document.body.classList.add('turbo-native')
    }
  }

  isTurboNative() {
    return navigator.userAgent.includes('Turbo Native')
  }
}
```

---

## Estimated Effort Breakdown

| Task | Effort | Priority | Status |
|------|--------|----------|--------|
| **Authentication Token System** | 1-2 weeks | 🔴 Critical | ✅ Done |
| **Safe Area Insets** | 1 day | 🔴 Critical | ✅ Done |
| **Touch Target Minimums** | 1 day | 🔴 Critical | ✅ Done |
| **iOS Meta Tags (all layouts)** | 0.5 day | 🔴 Critical | ✅ Done |
| **Offline Fallback Page** | 1 day | 🟡 High | ✅ Done |
| **App Icon** | 0.5 day | 🟡 High | ✅ Done |
| **Turbo Native View Variants** | 3-5 days | 🟡 High | ❌ Pending |
| **Turbo Frames** | 2-3 days | 🟡 High | ❌ Pending |
| **Navigation Configuration** | 3-5 days | 🟡 High | ❌ Pending |
| **Push Notifications** | 1 week | 🟢 Medium | ✅ Done |
| **Biometric Login** | 2-3 days | 🟢 Medium | ✅ Done |
| **Pull-to-refresh** | 1 day | 🟢 Medium | ✅ Done |
| **Haptic Feedback** | 0.5 day | 🟢 Medium | ✅ Done |
| **Testing & Polish** | 1 week | 🟢 Medium | ❌ Pending |
| **Total Remaining** | **1-2 weeks** | | |

---

## Readiness Checklist

| Requirement | Status | Notes |
|-------------|--------|-------|
| Mobile-first HTML | ✅ Ready | 430px max-width |
| Turbo/Gem | ✅ Ready | turbo-rails installed |
| Stimulus Controllers | ✅ Ready | 23 controllers exist |
| PWA Meta Tags | ✅ Ready | All layouts, iOS+Android |
| Auth Token System | ✅ Built | `has_secure_token` + `TurboNativeDetection` |
| Native Detection | ✅ Built | User-agent check in concern |
| Safe Area Insets | ✅ Applied | Header, content, banners, FAB, modal |
| Touch Targets | ✅ Applied | All interactive elements ≥44pt |
| Offline Support | ✅ Built | Branded offline page + SW caching |
| App Icon | ✅ Set | 1024x1024 PNG in asset catalog |
| Header + Burger Menu in Native | ✅ Built | Visible in native context (May 21 fix) |
| FAB + Quick Actions in Native | ✅ Built | Visible in native context (May 21 fix) |
| External URLs → Safari | ✅ Built | SceneDelegate `isInternalURL()` check (May 21) |
| PrivacyInfo.xcprivacy | ✅ Built | App Store compliance manifest (May 21) |
| ITSAppUsesNonExemptEncryption | ✅ Built | Info.plist entry (May 21) |
| Hotwire Native App Shell | ✅ Built | hotwire-native-ios via SPM, HotwireTabBarController, 3 tabs |
| Native Tab Bar | ✅ Built | Calendar / Tracking / Settings (May 22) |
| Path Configuration | ✅ Built | `/configurations/ios_v1.json` (settings/account → modal) |
| Web Nav Hidden in Native | ✅ Built | Burger menu + FAB hidden, tab bar replaces |
| PrivacyInfo.xcprivacy | ✅ Built | App Store compliance manifest |
| ITSAppUsesNonExemptEncryption | ✅ Built | Info.plist entry (May 21) |
| Scene Manifest | ✅ Built | UIApplicationSceneManifest in Info.plist |
| CI Workflow | ✅ Built | GitHub Actions: xcodegen → archive → sign → upload |
| All Icon Sizes | ✅ Built | Generated from 1024x1024 source |
| Path Configuration | ⏳ Future | JSON config for modal/sheet rules (post-launch) |
| Native Push Bridge (APNs) | ⏳ Future | Currently Web Push API only |
| Push Notifications | ✅ Built | Web Push API + Stimulus controller |
| Biometric Auth | ✅ Built | WebAuthn platform authenticator |
| Pull-to-refresh | ✅ Built | Touch-based Stimulus controller + spinner |
| Haptic Feedback | ✅ Built | `navigator.vibrate()` + CSS `:active` |

---

## Conclusion

## Development Constraints

| Constraint | Impact | Solution |
|-----------|--------|----------|
| macOS 12 (Monterey) | Max Xcode 14.2, Swift 5.7 | Hotwire Native needs Swift 5.9+ → **use CI** |
| 2015 MacBook Pro | Can't upgrade past macOS 12 | CI builds Hotwire Native, local tests with plain WKWebView |
| xcodebuild export | Requires Xcode Accounts on headless CI | **Manual codesign + altool upload** (see CI workflow) |

**Local development path:**
1. Make web app changes in Rails — test at `localhost:3000`
2. Push → CI compiles Hotwire Native iOS app (Xcode 16.4 cloud Mac)
3. CI signs manually → uploads to TestFlight
4. Test on physical device via TestFlight

**7 GitHub secrets required** (see `docs/STORE-DEPLOYMENT.md` for setup):
`DEVELOPMENT_TEAM`, `APPLE_ID`, `APP_SPECIFIC_PASSWORD`, `APPSTORE_KEY_ID`, `APPSTORE_ISSUER_ID`, `APPSTORE_KEY_BASE64`, `DIST_CERT_BASE64`, `DIST_CERT_PASSWORD`, `PROVISIONING_PROFILE_BASE64`
