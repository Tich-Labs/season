---
layout: default
---

# Native Parity Plan — iOS First, Then Android, Then Rails

**Created:** 3 September 2026, post-M7
**Status:** Planning — no implementation started yet

---

## Goal

Currently the app deploys to TestFlight via a real, hand-built Hotwire Native iOS project. After M7 ships, the plan is to go deeper on Hotwire Native across the board:

1. **iOS first** — clean up and finish what's already the more mature platform
2. **Android to parity** — bring the Android wrapper up to the same level, then into Play Store internal testing
3. **Rails-side pass** — make the server app itself more Turbo-idiomatic (real Turbo Streams instead of full-page reloads, fewer non-Turbo forms)

This order was a deliberate choice: iOS already has real bridge components and a CI pipeline to build from; Android is currently a bare scaffold; the Rails-side work benefits from having both native shells stable first.

---

## ⚠️ First, a documentation correction

Two existing docs (`docs/ios.md`, `docs/STORE-DEPLOYMENT.md`) describe a **custom auth-token bridge** — `TurboNativeDetection` concern, `has_secure_token :native_auth_token`, `X-Turbo-Native-Token` header, `NativeAuthTokenComponent.swift` writing to `KeychainHelper.swift`. Checked directly against the current repo (3 Sep 2026): **none of that exists anymore.**

- `app/controllers/concerns/turbo_native_detection.rb` — gone
- `native_auth_token` / `X-Turbo-Native-Token` — zero references anywhere in `app/`
- `NativeAuthTokenComponent.swift`, `KeychainHelper.swift` — gone from `ios/`
- `AppDelegate.swift`'s actual bridge registration today:

```swift
Hotwire.registerBridgeComponents([
    ButtonComponent.self,
    NotificationTokenComponent.self
])
```

So iOS auth today is plain cookie/session sharing through the WKWebView (the standard, simpler Hotwire Native pattern) — not a custom token bridge. Someone already did this simplification; the docs just never caught up. **Action item, cheap and worth doing early:** update `ios.md` and `STORE-DEPLOYMENT.md` to match reality before they mislead anyone else. Everything below is built on what's actually in the repo right now, not on those two docs.

---

## What we have vs. what we need

### iOS

| Area | Have | Need |
|---|---|---|
| Hotwire Native project | ✅ `hotwire-native-ios` via SPM, `ios/SeasonApp/` | — |
| Tab bar | ✅ Calendar / Tracking / Settings (`Tabs.swift`) | — |
| Path configuration | ✅ `/configurations/ios_v1.json` | — |
| Auth | ✅ Cookie/session via WebView (simplified from the old token bridge) | Confirm this is intentional, not an accidental regression — document it |
| Push notifications | ✅ `NotificationTokenComponent`, `NotificationRouter`, `NotificationTokenViewModel`, `NotificationToken` model | — |
| Native button bridge | ✅ `ButtonComponent.swift` (not documented anywhere yet) | Document what it's used for |
| CI | ✅ `.github/workflows/ios.yml` — xcodegen → archive → manual codesign → IPA → altool upload | — |
| App icon / launch screen | ✅ `Assets.xcassets`, `LaunchScreen.storyboard` | — |
| `ruby_native` gem | ✅ installed, used for `native_app?` detection, `native_form_tag` (4 forms), and its CSS (back-button visibility, safe-area classes) | Decide: keep or remove (see below) |
| E2E tests | ✅ `tests/app/`, `tests/auth/` (Playwright) | Confirm still green against current native auth flow |

### Android

| Area | Have | Need |
|---|---|---|
| Hotwire Native project | ✅ Gradle scaffold in `android/` | — |
| Tab bar definition | ✅ `Tabs.kt` (mirrors iOS's `Tabs.swift`) | Wire up to `MainActivity.kt` if not already |
| Path configuration | ✅ `/configurations/android_v1.json` already mirrors iOS's rules — **no Rails work needed here** | — |
| Auth | ❌ nothing native-side yet | Cookie/session via WebView, matching iOS's current (simplified) approach — no token bridge needed |
| Push notifications | ❌ | Kotlin equivalent of `NotificationTokenComponent` + `NotificationRouter` |
| App icon | ⚠️ present but Android Studio's default placeholder, not Season branding | Real icon set, all densities |
| Launch screen | ❌ | Android splash screen |
| CI | ❌ no workflow | GitHub Actions equivalent of `ios.yml` — Gradle build → AAB → upload |
| Play Console setup | ❌ | Internal testing track, store listing |

### Rails side (Phase 3)

| Area | Have | Need |
|---|---|---|
| Turbo Drive | ✅ active everywhere by default | — |
| Turbo Frames | ❌ none in the codebase | Introduce for the highest-value partial-update spots |
| Turbo Streams | ❌ none | Same |
| Known non-Turbo form | `calendar_events/new.html.erb` + `edit.html.erb` use `form_with ... local: true`, opting **out** of Turbo entirely | Root cause of the double-submit bug worked around earlier with a JS button-disable — converting to a real Turbo submit would fix it at the source instead |
| `ruby_native`'s footprint | Small — one detector, one CSS file, 4 form tags | Once native parity work is done, decide whether to keep it or hand-roll the equivalent (see below) |

---

## The `ruby_native` gem question

`ruby_native` (Joe Masilotti's gem — a *different*, lighter-weight "wrap your Rails app" product with its own companion app and QR-code preview flow) is installed but barely used: just `native_app?` (user-agent detection), `native_form_tag` on 4 forms, and its CSS file for back-button visibility and safe-area class names. It is **not** handling auth, push, or navigation — that's all the real custom Hotwire Native project.

**Recommendation: no new repo.** Its footprint is small enough that removing it, if/when it's in the way, is a same-repo, mechanical change — replace `native_app?` with a small hand-rolled check (ideally a header/cookie the native shells set explicitly, more reliable than user-agent sniffing), inline the couple of CSS rules actually used, drop the gem. Not worth the cost of a parallel repo (lost git history, a second deploy pipeline to keep in sync with Render) for a change this contained.

Decide this **after** Android reaches iOS parity, not before — no reason to touch it while the native-parity work is still in flight.

---

## Execution plan

### Phase 1a — iOS cleanup (do first, it's the smaller job)

1. Update `docs/ios.md` and `docs/STORE-DEPLOYMENT.md` to drop the stale auth-token-bridge content and document the current cookie/session approach instead
2. Document `ButtonComponent.swift` and `NotificationToken.swift` (currently undocumented additions)
3. Confirm `tests/app/`, `tests/auth/` Playwright suites still pass against the current (simplified) auth flow
4. Decide whether `ruby_native`'s `native_app?` should be replaced with something the native shells set explicitly, or left as-is for now

### Phase 1b — Android to parity

1. Auth: confirm cookie/session sharing works the same way as iOS (should, if it's a standard WKWebView/Android WebView cookie jar) — no custom bridge needed unless testing proves otherwise
2. Push: Kotlin equivalent of `NotificationTokenComponent` + `NotificationRouter`, registered the same way `AppDelegate.swift` does
3. Real app icon (replace the Android Studio placeholder) and a proper launch/splash screen
4. CI: `.github/workflows/android.yml` mirroring `ios.yml`'s shape (build → sign → AAB → upload), or as close as Android's simpler signing model allows
5. Play Console: internal testing track, store listing, screenshots

### Phase 2 — Rails-side Turbo-idiomatic pass

1. Convert `calendar_events/new.html.erb` / `edit.html.erb` off `form_with ... local: true` onto real Turbo — fixes the double-submit issue at the root instead of the current JS-disable workaround
2. Audit other full-page-reload spots for Turbo Frame candidates (the modal-heavy appointment flow is the biggest one)
3. Revisit the `ruby_native` gem question now that both native shells are stable

---

## Open questions to resolve before starting

- Was removing the custom auth-token bridge intentional, or did it get dropped incidentally during other work? (Doesn't block anything — cookie/session auth is the more standard approach — but worth confirming it wasn't an accident before building further on top of it.)
- Does Android's WebView cookie jar actually behave the same as iOS's WKWebView for session persistence? Worth a quick spike before assuming Phase 1b's auth step is a non-issue.
