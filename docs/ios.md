# Turbo Native iOS Integration - Audit & Roadmap

## Executive Summary

The Season app is **well-positioned** for Turbo Native integration. It's already built as a mobile-first PWA with Hotwire (Turbo + Stimulus), has a max-width 430px container design, and uses server-rendered HTML—the exact architecture Turbo Native is designed to wrap.

**Estimated Effort:** 3-5 weeks for a production-ready iOS app using the Frost framework approach.

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

### A. Authentication Bridge (Critical - 1-2 weeks)

**Problem:** Cookie-based auth doesn't work well with Turbo Native's WKWebView

**Solution:** Implement token-based auth system (see Authentication section above)

### B. Request Variant Detection (1-2 days)

```ruby
# app/controllers/concerns/turbo_native_detection.rb
module TurboNativeDetection
  extend ActiveSupport::Concern

  included do
    before_action :set_request_variant
  end

  private

  def set_request_variant
    request.variant = :turbo_native if turbo_native_app?
  end

  def turbo_native_app?
    request.user_agent&.match?(/Turbo Native|Season iOS/i)
  end
end
```

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

### D. iOS App Setup with Frost (1-2 weeks)

**Frost Framework Integration:**

```swift
// AppDelegate.swift
import UIKit
import Turbo

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var session: Session!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        session = Session()

        let rootViewController = RootViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()

        // Navigate to your Rails app
        let url = URL(string: "https://season.vision")!
        session.visit(url)

        return true
    }
}
```

**Handle Authentication in iOS App:**
```swift
// After login success, capture auth token
func handleLoginSuccess(authToken: String) {
    UserDefaults.standard.set(authToken, forKey: "native_auth_token")
    // Store in Keychain for production
}

// Inject token into requests
extension URLRequest {
    mutating func addTurboNativeHeaders() {
        if let token = UserDefaults.standard.string(forKey: "native_auth_token") {
            setValue(token, forHTTPHeaderField: "X-Turbo-Native-Token")
        }
        setValue("Season iOS Turbo Native", forHTTPHeaderField: "User-Agent")
    }
}
```

### E. Navigation Bridging (3-5 days)

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

---

## Key Files to Modify/Create

### New Files to Create:
```
1. app/controllers/concerns/turbo_native_detection.rb
2. app/models/user_native_token.rb (or add to User model)
3. config/initializers/turbo_native.rb
4. app/views/layouts/turbo_native.html.erb (optional variant)
5. public/turbo_native_config.json (for iOS app path config)
6. app/helpers/turbo_native_helper.rb
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
| **Authentication Token System** | 1-2 weeks | 🔴 Critical |
| **Request Variant Detection** | 1-2 days | 🔴 Critical |
| **Native-Specific Views** | 3-5 days | 🟡 High |
| **iOS App (Frost/Turbo Native)** | 1-2 weeks | 🔴 Critical |
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
| Auth Token System | ❌ Missing | Must build for native |
| Native Detection | ❌ Missing | Need request variant |
| iOS App Shell | ❌ Missing | Need to build in Swift |
| Path Configuration | ❌ Missing | JSON config for native |
| Offline Support | ❌ Optional | Service worker exists but basic |

---

## Conclusion

The Season app is **architecturally well-suited** for Turbo Native integration. The primary work involves:

1. **Building a token-based auth bridge** (biggest gap)
2. **Creating an iOS app shell** with Frost/Turbo Native
3. **Adding request variant detection** for native-specific responses
4. **Configuring native navigation** patterns

The Hotwire foundation is solid, the mobile-first design is excellent, and the Stimulus controllers provide the interactivity needed. With 3-5 weeks of focused effort, you could have a production-ready iOS app in the App Store using Turbo Native.

**Recommendation:** Start with the authentication token system first, then build a minimal iOS wrapper to test the integration before investing in native-specific views and navigation polish.
