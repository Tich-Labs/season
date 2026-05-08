---
layout: default
---

# Turbo Native iOS Integration - Audit & Roadmap

## Hotwire Native iOS Progress Checklist

| # | Task                                                                 | Status     | Notes |
|---|----------------------------------------------------------------------|------------|-------|
| 1 | Add turbo-ios SPM to ios/SeasonApp/                                 | ✅ Complete | SPM dependency added in project.yml |
| 2 | Rewrite SceneDelegate.swift — replace plain WKWebView with Hotwire Native Navigator, load tabs | ✅ Complete | SceneDelegate.swift uses TurboNavigator |
| 3 | configurations_controller.rb — GET /configurations/ios_v1.json with path rules (modal/new/edit patterns, pull-to-refresh) | ✅ Complete | Implemented in ConfigurationsController#ios_v1 |
| 4 | native.css — .d-hotwire-native-none (hide web UI), .d-hotwire-native-block (native-only elements) | ✅ Complete | native.css created with utility classes |
| 5 | data-hotwire-native attribute on <html> when request is from native app | ✅ Complete | All layouts updated |
| 6 | Hide web navbar/burger menu in native app (<% unless hotwire_native_app? %>) | ✅ Complete | Conditional logic in application.html.erb |
| 7 | Clean up AppDelegate.swift — remove legacy WKWebView/window code (SceneDelegate handles UI) | ✅ Complete | AppDelegate is now a minimal stub |
| 8 | Rename HotwireTab.swift → Tabs.swift and update references | ✅ Complete | `Tab` struct in Tabs.swift |
| 9 | Make base URL configurable via Info.plist (SEASON_BASE_URL) instead of hardcoded | ✅ Complete | HotwireTabBarController reads from Bundle.main |
| 10 | Fix project.yml source paths and Info.plist location | ✅ Complete | Sources: SeasonApp, Info.plist: SeasonApp/Info.plist |
| 11 | Wait for Apple Dev Account — needed to build + install on device     | ⏳ Pending  | External dependency |
| 12 | Regenerate .xcodeproj from updated project.yml (xcodegen requires Xcode 15.3+) | ⏳ Pending  | Blocked by macOS 12 on current machine |
| 13 | APNs Push (optional phase 2) — replace Web Push with APNs for native app users, keep both paths | ⏳ Pending  | Not started |

---

## Executive Summary

The Season app is **well-positioned** for Turbo Native integration. It's already built as a mobile-first PWA with Hotwire (Turbo + Stimulus), has a max-width 430px container design, and uses server-rendered HTML—the exact architecture Turbo Native is designed to wrap.

**Estimated Effort:** 3-5 weeks for a production-ready iOS app using Turbo Native.

---

## Current Tech Stack Analysis

### What's Already in Place ✅

| Component | Status | Notes |
|-----------|--------|-------|
| **Rails 8.1.3** | ✅ Ready | Modern Rails with Hotwire built-in |
| **Turbo Rails** | ✅ Installed | v2.0.23, fully integrated |
| **Stimulus** | ✅ Active | 17 controllers (incl. `calendar_toggle_controller`) |
| **Import Maps** | ✅ Configured | No Node/build dependencies |
| **Mobile-First CSS** | ✅ Excellent | Tailwind, max-w-[430px] container |
| **PWA Infrastructure** | ✅ Present | Manifest, service worker, meta tags |
| **Cookie Auth** | ⚠️ Needs Work | Must be adapted for native |
| **Calendar Preferences** | ✅ Complete | 5 toggles: appointments, cycle days, moon phases, holidays, week numbers |

### Key Files
- `Gemfile` (lines 15-16: turbo-rails, stimulus-rails)
- `config/importmap.rb` (Turbo + Stimulus pinned)
- `app/javascript/application.js` (imports Turbo and controllers)

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
- **Turbo Streams:** Used in `FeedbacksController#create`
- **Turbo Frames:** NOT currently used (none found in views)
- **Stimulus Controllers:** 16 controllers in `app/javascript/controllers/`

**Stimulus Controllers Available:**
1. `menu_controller.js` - Burger menu (open/close/slider)
2. `quick_actions_controller.js` - Modal management
3. `calendar_index_controller.js` - Dropdown toggle
4. `symptom_controller.js` - Symptom logging
5. `date_picker_controller.js` - Date selection
6. `feedback_modal_controller.js` - Feedback forms
7. `open_feedback_controller.js` - Feedback triggers
8. `loader_controller.js` - Loading states
9. `launch_signup_controller.js` - Waitlist signup
10. `install_controller.js` - PWA installation (iOS/Android)
11. `password_visibility_controller.js` - Password toggle
12. `countdown_controller.js` - Launch countdown
13. `feature_slides_controller.js` - Feature carousel
14. `update_prompt_controller.js` - Update prompts
15. `coming_soon_controller.js` - Coming soon features
16. `hello_controller.js` - Sample controller

---

## Authentication System - Critical Gap

### Current Implementation
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
end
```

### Issues for Turbo Native:
1. **Cookie-based auth won't work directly** - Turbo Native uses `WKWebView` which handles cookies differently
2. **No token-based auth** - No JWT or API tokens for native app authentication
3. **Session storage** - Uses both `session[:user_id]` and `cookies.encrypted[:user_id]`

### Recommended Solution: Token-Based Auth

```ruby
# Add to User model
class User < ApplicationRecord
  has_secure_token :native_auth_token

  def native_auth_token_valid?
    native_auth_token_updated_at > 30.days.ago
  end
end

# In ApplicationController or new concern
class ApplicationController < ActionController::Base
  before_action :authenticate_for_turbo_native

  private

  def authenticate_for_turbo_native
    if turbo_native_app?
      token = request.headers['X-Turbo-Native-Token']
      user = User.find_by(native_auth_token: token)
      if user&.native_auth_token_valid?
        Current.user = user
      else
        render json: {error: 'Unauthorized'}, status: :unauthorized
      end
    end
  end

  def turbo_native_app?
    request.user_agent&.include?('Turbo Native')
  end
end
```

---

## Layout Structure Analysis

### Mobile-First Design ✅
```erb
<!-- app/views/layouts/application.html.erb -->
<body class="bg-[#FCF9F7] font-['Montserrat'] antialiased h-full overflow-x-hidden">
  <main class="w-full flex-1 <%= is_authenticated_view ? 'pt-24' : '' %>">
    <div class="max-w-md mx-auto h-full">
      <%= yield %>
    </div>
  </main>
</body>
```

### Key Observations:
1. **Already constrained to mobile viewport** - `max-w-md` (approx 430px-480px)
2. **Meta tags present:**
   - `mobile-web-app-capable`
   - `apple-mobile-web-app-capable` (launch.html.erb)
   - Viewport meta with `viewport-fit=cover` (important for iPhone X+ notch)
3. **Top App Bar** - Fixed position header with hamburger menu
4. **No Turbo Native specific layout** - Would need a variant or conditional rendering

---

## Response Formats

| Format | Usage | Turbo Native Compatibility |
|--------|-------|---------------------------|
| HTML | Primary | ✅ Native support via Turbo |
| Turbo Stream | FeedbacksController | ✅ Works with Turbo Native |
| JSON | Symptoms#create, Account#show | ⚠️ Need to add format detection |
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
2. **Burger menu** - Uses `menu_controller.js` with slide-out panel
3. **No deep linking support** - Turbo Native URLs need proper handling

---

## Existing iOS/Mobile Code

### PWA Install Controller (`install_controller.js`):
```javascript
// Detects iOS vs Android for PWA installation
this._isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream
```

### iOS Meta Tags:
- `apple-mobile-web-app-capable` (launch.html.erb)
- `apple-touch-icon` links in both layouts
- `theme-color` set to `#933a35` (brand primary)

---

## Gaps to Fill

### A. Authentication Bridge (Critical) ✅ Implemented

**Solution:** Token-based auth via `TurboNativeDetection` concern.

- `native_auth_token` column on users (migration `20260519170000`)
- `has_secure_token :native_auth_token` + `regenerate_native_auth_token!` on User model
- `TurboNativeDetection` concern included in ApplicationController:
  - Detects `HTTP_X_HOTWIRE_NATIVE` header + `Turbo Native` user agent
  - Sets `request.variant = :turbo_native`
  - Authenticates via `X-Turbo-Native-Token` header
- Token regenerated on every native login (via `Authentication#login`)
- `<meta name="native-auth-token">` injected in application layout for authenticated native pages

### B. Request Variant Detection (1-2 days) ✅ Implemented

Done via `TurboNativeDetection` concern (see `app/controllers/concerns/turbo_native_detection.rb`):

```ruby
def detect_turbo_native
  return unless turbo_native_app?
  request.variant = :turbo_native
  authenticate_native_token if request.headers["X-Turbo-Native-Token"].present?
end
```

`turbo_native_app?` is available as a view helper for conditional rendering.

### C. Native-Specific Views (3-5 days)

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

### D. iOS App Setup with turbo-ios (1-2 weeks) ✅ Shell built

**Current Implementation:**

```swift
// SceneDelegate.swift — entry point
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = HotwireTabBarController()
        window.makeKeyAndVisible()
    }
}

// Tabs.swift — tab model
struct Tab {
    let title: String
    let systemImageName: String
    let urlPath: String
}

// HotwireTabBarController.swift — tab bar with TurboNavigator
class HotwireTabBarController: UIViewController, UITabBarDelegate {
    private let turboNavigator = TurboNavigator()
    private let baseURL: String = {
        Bundle.main.object(forInfoDictionaryKey: "SEASON_BASE_URL") as? String
            ?? "https://seasonv2.onrender.com"
    }()
    private let tabs: [Tab] = [
        Tab(title: "Calendar", systemImageName: "calendar", urlPath: "/calendar"),
        Tab(title: "Daily", systemImageName: "calendar.circle", urlPath: "/daily"),
        Tab(title: "Tracking", systemImageName: "chart.pie", urlPath: "/tracking")
    ]
    // ... UITabBar with TurboNavigator root view controller
}
```

**Key Points:**
- Uses `turbo-ios` (SPM: `https://github.com/hotwired/turbo-ios.git`, v1.4.0), not Frost
- `AppDelegate` is a minimal stub — all window creation in `SceneDelegate`
- Base URL in `Info.plist` key `SEASON_BASE_URL`, not hardcoded
- Regenerate `.xcodeproj` with `xcodegen generate` from `ios/SeasonApp/`

### E. Navigation Bridging (3-5 days) ✅ Server-side config done

Turbo Native needs to handle:
1. **Modal presentations** - Settings, symptoms forms present as modals
2. **Pull-to-refresh** - Enabled on /calendar and /daily/*
3. **Haptic feedback** - For interactions (future)

Path configuration is served from the Rails backend:

```bash
GET /configurations/ios_v1.json
```

```json
{
  "rules": [
    {
      "patterns": ["/calendar", "/daily/*"],
      "properties": {"presentation": "default", "pull_to_refresh": true}
    },
    {
      "patterns": ["/settings/*", "/symptoms/new", "/symptoms/edit"],
      "properties": {"presentation": "modal"}
    }
  ]
}
```

---

## Key Files to Modify/Create

### Existing iOS Files:
```
1. ios/SeasonApp/project.yml — XcodeGen spec (SPM turbo-ios 1.4.0)
2. ios/SeasonApp/SeasonApp/SceneDelegate.swift — Entry point, creates HotwireTabBarController
3. ios/SeasonApp/SeasonApp/AppDelegate.swift — Minimal stub (no WKWebView/window)
4. ios/SeasonApp/SeasonApp/Tabs.swift — Tab model struct
5. ios/SeasonApp/SeasonApp/HotwireTabBarController.swift — Tab bar with TurboNavigator
6. ios/SeasonApp/SeasonApp/Info.plist — App config + SEASON_BASE_URL
```

### Files to Create:
```
1. app/controllers/concerns/turbo_native_detection.rb
2. app/models/user_native_token.rb (or add to User model)
3. config/initializers/turbo_native.rb
4. app/views/layouts/turbo_native.html.erb (optional variant)
5. app/helpers/turbo_native_helper.rb
```

### Files to Modify:
```
1. app/controllers/application_controller.rb
   - Include TurboNativeDetection concern

2. app/controllers/sessions_controller.rb
   - Return auth token for native app after login

3. app/controllers/registrations_controller.rb
   - Return auth token for native app after signup

4. app/views/layouts/application.html.erb
   - Add conditional for native app (hide burger menu if native handles it)

5. config/routes.rb
   - Add native auth endpoint if using token approach

6. app/javascript/controllers/menu_controller.js
   - Disable or adapt for native (native app has its own nav)
```

---

## Architectural Recommendations

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
      // Disable web-only features
    }
  }

  isTurboNative() {
    return navigator.userAgent.includes('Turbo Native')
  }
}
```

---

## Estimated Effort Breakdown

| Task | Effort | Priority |
|------|--------|----------|
| **Authentication Token System** | 1-2 weeks | ✅ Complete |
| **Request Variant Detection** | 1-2 days | ✅ Complete |
| **Native-Specific Views** | 3-5 days | 🟡 High |
| **iOS App (Turbo Native)** | 1-2 weeks | 🔴 Critical |
| **Navigation Configuration** | 3-5 days | 🟡 High |
| **Testing & Polish** | 1 week | 🟢 Medium |
| **Total** | **3-5 weeks** | |

---

## Readiness Checklist

| Requirement | Status | Notes |
|-------------|--------|-------|
| Mobile-first HTML | ✅ Ready | 430px max-width |
| Turbo/Gem | ✅ Ready | turbo-rails installed |
| Stimulus Controllers | ✅ Ready | 16 controllers exist |
| PWA Meta Tags | ✅ Ready | iOS/Android tags present |
| iOS App Shell (Swift) | ✅ Ready | TurboNavigator + tab bar built |
| Path Configuration | ✅ Ready | /configurations/ios_v1.json implemented |
| Base URL Configuration | ✅ Ready | SEASON_BASE_URL in Info.plist |
| Auth Token System | ✅ Ready | Token-based auth via native_auth_token, TurboNativeDetection concern, meta tag injection |
| Native Detection | ✅ Ready | TurboNativeDetection sets request variant, UA header checks |
| Offline Support | ❌ Optional | Service worker exists but basic |

---

## Conclusion

The Season app is **architecturally well-suited** for Turbo Native integration. The primary work involves:

1. ~~**Building a token-based auth bridge**~~ (done)
2. ~~**Adding request variant detection**~~ (done)
3. **Creating native-specific view variants** with `+turbo_native.erb` templates

The Hotwire foundation is solid, the mobile-first design is excellent, and the Stimulus controllers provide the interactivity needed. The iOS shell is built with turbo-ios, a tab bar with 3 tabs (Calendar/Daily/Tracking), and a server-side path configuration endpoint. Next steps focus on authentication bridging and native request variant detection.

**Recommendation:** Next step is creating `+turbo_native.erb` view variants for calendar, sessions, and onboarding to optimise the native experience.
