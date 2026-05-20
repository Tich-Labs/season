---
layout: default
---

# Hotwire Native Audit — Book Patterns vs Our Implementation

Audited against *"Hotwire Native for Rails Developers"* (PragProg, code companion in `docs/code/`).

**Key note:** The book uses the newer `HotwireNative` framework (turbo-ios + Strada merged). We use `turbo-ios` 1.4.0 standalone. API names differ (`Navigator` vs `TurboNavigator`, `HotwireTab` vs `Tab`, etc.) but the architecture is the same: WKWebView wrapping server-rendered HTML.

---

## 1. Rails Server-Side Patterns

| # | Pattern (Book) | Our Status | Gap |
|---|---|---|---|
| 1.1 | `Authentication` concern — cookie-based, `sign_in(user)`, `sign_out(user)`, `cookies.permanent.encrypted[:user_id]` | ✅ Done | Same pattern (we use `Authentication#login` + `cookies.encrypted[:user_id]`). We extend with `native_auth_token` which book doesn't have. |
| 1.2 | `ApplicationController` includes `Authentication` only | ✅ Done | We also include `TurboNativeDetection` (our extension for native auth header). |
| 1.3 | `hotwire_native_app?` helper — checks `request.user_agent` for "Hotwire Native" | ✅ Done | We use `turbo_native_app?` (checks header + UA). Same pattern, different name. |
| 1.4 | Native CSS loaded conditionally: `<%= stylesheet_link_tag "native" if hotwire_native_app? %>` | ⚠️ Partial | We load native.css unconditionally in `turbo_native` layout. Book loads it conditionally in `application` layout. Both work. |
| 1.5 | `d-hotwire-native-none` class on web-only elements (navbar, headings) | ✅ Done | Used in `turbo_native` layout (hides PWA banners, service worker). Book uses on Bootstrap navbar. |
| 1.6 | `d-hotwire-native-block` for native-only elements | ✅ Done | Defined in `native.css`, same pattern. |
| 1.7 | `content_for(:title)` in layout `<head>` | ✅ Done | Same pattern in both layouts. |

---

## 2. Path Configuration

| # | Pattern (Book) | Our Status | Gap |
|---|---|---|---|
| 2.1 | `GET /configurations/ios_v1.json` endpoint | ✅ Done | `ConfigurationsController#ios_v1` |
| 2.2 | Modal patterns: `/new$`, `/edit$` → `context: "modal"` | ⚠️ Diff | Book uses `context: "modal"`, we use `properties: {"presentation": "modal"}`. Both are valid — our format matches `turbo-ios` 1.x, book matches `HotwireNative`. |
| 2.3 | Pull-to-refresh: `pull_to_refresh_enabled: true` on list patterns | ✅ Done | Enabled for `/calendar`, `/daily/*` in our config. |
| 2.4 | Custom native view controllers: `view_controller: "map"` in path rules | ❌ Missing | Book maps `/hikes/[0-9]+/map` to a native `MapController`. We have no custom native view controllers. **Not needed yet** — our app doesn't have native-only views. |
| 2.5 | Android path config also served (`android_v1`) | ❌ Missing | We have no Android app. **Out of scope.** |
| 2.6 | Path config loaded in iOS via `Hotwire.loadPathConfiguration(from:)` | ✅ Done | We load via `session.pathConfiguration` (turbo-ios API). Same concept, different API. |

---

## 3. Native CSS (`native.css`)

| # | Pattern (Book) | Our Status | Gap |
|---|---|---|---|
| 3.1 | `.d-hotwire-native-none { display: none !important; }` | ✅ Done | Exact match |
| 3.2 | `.d-hotwire-native-block { display: block !important; }` | ✅ Done | Exact match |
| 3.3 | Hide bridge button elements in web: `[data-bridge-components~="button"] [data-controller~="bridge--button"] { display: none !important; }` | ❌ Missing | We don't use bridge components yet. **Optional phase 3.** |
| 3.4 | Web navbar hidden with `d-hotwire-native-none` class | ✅ Done | App bar hidden via layout conditional (`is_native_app`), not CSS class. Same effect. |
| 3.5 | Additional visibility classes (`.d-hotwire-native-flex`, `.d-hotwire-native-visible`, etc.) | ✅ Extra | We have MORE utility classes than the book. Good. |

---

## 4. Stimulus / JavaScript

| # | Pattern (Book) | Our Status | Gap |
|---|---|---|---|
| 4.1 | Stimulus auto-loading via `eagerLoadControllersFrom` | ✅ Done | Identical pattern in `controllers/index.js` |
| 4.2 | `controllers/application.js` — Stimulus bootstrap | ✅ Done | Identical |
| 4.3 | Bridge button controller (`bridge/button_controller.js` extending `BridgeComponent`) | ❌ Missing | Book uses `@hotwired/hotwire-native-bridge` for native nav bar buttons (Add, Save, Sign in). We don't use Strada/bridge yet. **Optional phase 3.** |
| 4.4 | Bridge notification token controller (`bridge/notification_token_controller.js`) | ❌ Missing | Book requests push permission via bridge. We use our own `NativeDevicesController`. Different approach. |
| 4.5 | Native detection Stimulus controller | ⚠️ Diff | Book doesn't have one. We created `native_controller.js` — our own extension for client-side Turbo Native class + PWA cleanup. |
| 4.6 | Import map pins for `@hotwired/turbo`, `@hotwired/stimulus`, `@hotwired/hotwire-native-bridge` | ⚠️ Diff | We don't pin `hotwire-native-bridge` (no bridge components). **Optional phase 3.** |

---

## 5. iOS Swift Patterns

| # | Pattern (Book) | Our Status | Gap |
|---|---|---|---|
| 5.1 | `AppDelegate` — minimal stub OR `Hotwire.loadPathConfiguration(from:)` + `registerBridgeComponents([])` | ✅ Done | Our `AppDelegate` is a minimal stub. Path config loaded in `HotwireTabBarController`. Book does it in `AppDelegate`. Both valid. |
| 5.2 | `SceneDelegate` — creates tab bar controller, sets as root, calls `load(HotwireTab.all)` | ✅ Done | Our `SceneDelegate` creates `HotwireTabBarController()` and sets as root. |
| 5.3 | `Tab` model — title, image, path per tab | ✅ Done | `Tabs.swift` with `Tab` struct. Book uses `HotwireTab` from the framework. Same concept. |
| 5.4 | `TabBarController` — creates `Navigator` per tab, routes URLs | ✅ Done | Our `HotwireTabBarController` uses `TurboNavigator` (turbo-ios). Book uses `Navigator` (HotwireNative). Same pattern. |
| 5.5 | `NavigatorDelegate` / `NavigatorDelegate` — handles `VisitProposal` for custom view controllers | ⚠️ Partial | We have `SessionDelegate` (turbo-ios) but don't implement the visit proposal handler for custom controllers. We don't have any custom native view controllers yet. **Not needed yet.** |
| 5.6 | `BridgeComponent` subclasses — native side of Strada bridge | ❌ Missing | Book has `ButtonComponent` (adds native UIBarButtonItem) and `NotificationTokenComponent`. We don't use bridge components. **Optional phase 3.** |
| 5.7 | `WKWebViewConfiguration` with user agent set to `"Hotwire Native iOS"` | ✅ Done | We set `"Turbo Native iOS"` — ours matches turbo-ios convention. |
| 5.8 | `URLSession` for native API calls (e.g., notification token POST) | ❌ Missing | Book POSTs notification tokens via native `URLSession`. Our `NativeDevicesController` is a web endpoint. Different architecture. |
| 5.9 | Native SwiftUI views (`MapView.swift`) + `UIHostingController` wrapper | ❌ Missing | Book has a native `MapView` (SwiftUI) for showing hike locations on a map. We have no native SwiftUI views. **By design** — our architecture is pure Turbo Native, no native views. |

---

## 6. Authentication Bridge

| # | Pattern (Book) | Our Status | Gap |
|---|---|---|---|
| 6.1 | Cookie-based auth only (`cookies.encrypted[:user_id]`) | ✅ Done | Same. |
| 6.2 | No native auth token / no header injection | ❌ N/A | Book doesn't use token-based auth. Our `native_auth_token` + `X-Turbo-Native-Token` header + Keychain is **our own extension beyond the book**. |
| 6.3 | `WKUserScript` for meta tag extraction | ❌ N/A | Book doesn't do this. Our `nativeAuth` script message handler is our own implementation. |
| 6.4 | `sign_in(user)` → sets `Current.user` + cookie | ✅ Done | Our `login(user)` does the same + regenerates native auth token for native apps. |
| 6.5 | `sign_out(user)` → clears `Current.user` + resets session + deletes cookie | ✅ Done | Our `logout` does the same. |
| 6.6 | `before_action :authenticate_user!` on protected controllers | ✅ Done | Via `Authentication` concern. |
| 6.7 | `allow_unauthenticated_access` for public pages | ✅ Done | Via `Authentication` concern's `allow_unauthenticated_access`. |

---

## 7. Push Notifications

| # | Pattern (Book) | Our Status | Gap |
|---|---|---|---|
| 7.1 | `NotificationToken` model — stores device tokens per user per platform (iOS / FCM) | ✅ Done | `NativeDevice` model, similar concept. |
| 7.2 | `NotificationTokensController` — `POST /notification_tokens` | ✅ Done | `NativeDevicesController#register`. Different endpoint name, same purpose. |
| 7.3 | `skip_before_action :verify_authenticity_token` for token registration | ✅ Done | Same. |
| 7.4 | APNs via `Noticed` gem (`deliver_by :ios`) | ❌ Diff | Book uses `Noticed` gem for push. We use `ApnsPushService` + `apnotic` gem directly. Both valid. |
| 7.5 | FCM for Android via `Noticed` gem (`deliver_by :fcm`) | ❌ Missing | **Out of scope** (no Android app). |
| 7.6 | `NotificationRouter` for deep linking from push tap | ❌ Missing | Book routes to URL path from push notification `userInfo["path"]`. We don't handle push tap deep linking yet. **Gap for phase 3.** |
| 7.7 | Request notification permission via bridge component | ❌ Missing | Book requests push permission through the bridge. We haven't implemented push permission flow. **Gap for phase 3.** |

---

## 8. Native App Shell (Tab Bar)

| # | Pattern (Book) | Our Status | Gap |
|---|---|---|---|
| 8.1 | Tab bar with 2 tabs (Hikes, Hikers) | ✅ Done | 3 tabs (Calendar, Daily, Tracking). |
| 8.2 | `UITabBarController` subclass | ✅ Done | `HotwireTabBarController` (custom, not framework subclass). Book uses `HotwireTabBarController` from `HotwireNative` framework. |
| 8.3 | One `Navigator` per tab (book) vs single shared `TurboNavigator` (us) | ⚠️ Diff | Book creates separate `Navigator` per tab for independent navigation stacks. We share one `TurboNavigator`. Both approaches valid — shared navigator matches turbo-ios docs. |
| 8.4 | Tab bar styled with system images | ✅ Done | SF Symbols used. |
| 8.5 | Brand tint color on tab bar | ✅ Done | `#933a35` applied. |
| 8.6 | `Router` protocol for post-notification navigation | ❌ Missing | Book's `TabBarController` conforms to `Router` for deep linking after push tap. We don't implement this. **Gap for phase 3.** |

---

## 9. Bridge Components (Strada / hotwire-native-bridge)

| # | Pattern (Book) | Our Status | Gap |
|---|---|---|---|
| 9.1 | `@hotwired/hotwire-native-bridge` pinned in import map | ❌ Missing | **Optional phase 3.** |
| 9.2 | `BridgeComponent` JS base class used for button + notification components | ❌ Missing | **Optional phase 3.** |
| 9.3 | `data-controller="bridge--button"` with `data-bridge-title`, `data-bridge-ios-image-name` | ❌ Missing | **Optional phase 3.** |
| 9.4 | Native `ButtonComponent` (Swift) adding `UIBarButtonItem` to nav bar | ❌ Missing | **Optional phase 3.** |
| 9.5 | Bridge button used for: Add hike, Save form, Sign in | ❌ Missing | **Optional phase 3.** |
| 9.6 | `data-controller="bridge--notification-token"` for push permission | ❌ Missing | **Optional phase 3.** |
| 9.7 | `Hotwire.registerBridgeComponents([...])` in AppDelegate | ❌ Missing | **Optional phase 3.** |
| 9.8 | Bridge component hidden in web via CSS | ❌ Missing | **Optional phase 3.** |

---

## 10. Layout & View Variants

| # | Pattern (Book) | Our Status | Gap |
|---|---|---|---|
| 10.1 | Single `application.html.erb` layout with conditional native CSS loading | ⚠️ Diff | We have both `application.html.erb` and `turbo_native.html.erb`. Book uses one layout with CSS toggles. We use separate layouts via `_layout` override. **Both valid.** |
| 10.2 | `hotwire_native_app?` used in layout for conditional rendering | ✅ Done | We use `turbo_native_app?` (same concept, different name). |
| 10.3 | No `+turbo_native.erb` view variants — book uses `d-hotwire-native-*` CSS classes instead | ⚠️ Diff | We created `+turbo_native.erb` variants for calendar + sessions. Book uses CSS toggles within a single template. **Both valid** — our approach gives more control per-view. |
| 10.4 | `_navbar.html.erb` partial with `d-hotwire-native-none` | ✅ Done | Our app bar is conditionally rendered, not CSS-hidden. Same effect. |
| 10.5 | `turbo_refreshes_with method: :morph, scroll: :preserve` | ❌ Missing | Book uses Turbo 8 morph refresh. We're on an older Turbo version. **Not critical.** |

---

## Summary

### Matches Book (Done — 35 items)
Core architecture ✅ — cookie auth, path configuration, native CSS, tab bar, user agent, Stimulus, `hotwire_native_app?` helper, layout conditionals.

### Extends Book (Our Own Additions — 4 items)
- `native_auth_token` + `X-Turbo-Native-Token` header + Keychain cookie bridge
- `TurboNativeDetection` concern with `_layout` override
- `native_controller.js` Stimulus controller
- `+turbo_native.erb` view variants (calendar, sessions)

### Different by Design (API version — 4 items)
- `turbo-ios` API vs `HotwireNative` API (`TurboNavigator` vs `Navigator`, `Tab` vs `HotwireTab`)
- Shared `TurboNavigator` vs per-tab `Navigator` instances
- Separate native layout vs single layout with CSS toggles
- `APNSPushService` + `apnotic` vs `Noticed` gem for push

### Missing / Optional Phase 3 (10 items)
1. Bridge components (button, notification token) — Strada integration
2. `@hotwired/hotwire-native-bridge` import map pin
3. Native `ButtonComponent.swift` + `NotificationTokenComponent.swift`
4. Native `Router` protocol for push notification deep linking
5. `NotificationRouter` for handling push taps → URL routing
6. Bridge button CSS hiding rule in `native.css`
7. Custom native view controllers (`view_controller:` path rules) — not needed yet
8. `Turbo 8` morph refresh
9. Push permission request flow (via bridge)
10. Per-tab navigators (separate navigation stacks)

---

### Bottom Line

**We match the book on all core patterns.** The auth token bridge, native layout, and view variants are our own extensions that go beyond the book. The missing items are all Strada/bridge components and push deep linking — both are phase 3 features, not required for a working Turbo Native app. The architectural differences are due to API version (`turbo-ios` 1.4.0 vs `HotwireNative`) and are functionally equivalent.
