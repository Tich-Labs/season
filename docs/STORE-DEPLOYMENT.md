# App Store & Play Store — Deployment Setup Guide

**Last updated:** 2026-05-26
**App:** Season (Hotwire Native wrappers around the Rails PWA)

---

## Architecture

The web app runs on Render at `https://seasonv2.onrender.com`. iOS and Android use **Hotwire Native** — native tab bars (Calendar / Tracking / Settings) replace the web burger menu. All content is server-rendered HTML.

---

## Pre-Push Workflow

Every `git push` auto-runs lint checks via `.git/hooks/pre-push`. If any fail, push is blocked.

```bash
# Manual checks before push:
bundle exec rubocop && bundle exec erb_lint --lint-all && npx standard tests/

# Full E2E (needs bin/dev running):
npx playwright test
npx playwright show-report

# Setup hook on new machines:
bin/setup-hooks
```

---

## What's Done

| Item | iOS | Android |
|------|-----|---------|
| Hotwire Native integrated | ✅ `hotwire-native-ios` v1.2.2 (SPM) | ✅ `hotwire-native-android` (Gradle) |
| Native tab bar (3 tabs) | ✅ Calendar / Tracking / Settings | ✅ Calendar / Tracking / Settings |
| Auth token flow | ✅ `X-Turbo-Native-Token` | ✅ Same |
| Path configuration | ✅ `/configurations/ios_v1` | ✅ `/configurations/android_v1` |
| Web nav hidden in native | ✅ Burger + FAB hidden, tab bar replaces | ✅ Same |
| Tab bar hidden on auth screens | ✅ Login, signup, onboarding, welcome | ✅ Same |
| App icon (all sizes) | ✅ | ❌ |
| Launch screen | ✅ Storyboard | ❌ |
| PrivacyInfo.xcprivacy | ✅ | N/A |
| CI workflow | ✅ (xcodegen → archive → manual sign → IPA → upload) | ❌ |
| Pre-push hook | ✅ (rubocop + erb_lint + standard) | N/A |
| E2E tests | ✅ 32 Playwright smoke tests | N/A |
| Manual codesign (headless CI) | ✅ dist cert + provisioning profile | N/A |
| Bundle ID | `com.season-app.ios` | `com.seasonapp.android` |

---

## GitHub Secrets (9 required)

| Secret | Source |
|--------|--------|
| `DEVELOPMENT_TEAM` | `28NDQR5JC4` (Apple Developer Membership) |
| `APPLE_ID` | Developer Apple ID |
| `APP_SPECIFIC_PASSWORD` | appleid.apple.com → App-Specific Passwords |
| `APPSTORE_KEY_ID` | App Store Connect → Integrations → API Keys |
| `APPSTORE_ISSUER_ID` | Same page, Issuer ID at top |
| `APPSTORE_KEY_BASE64` | `base64 -i ~/Downloads/AuthKey_XXX.p8` |
| `DIST_CERT_BASE64` | Base64 of distribution certificate .p12 |
| `DIST_CERT_PASSWORD` | p12 password |
| `PROVISIONING_PROFILE_BASE64` | `base64 -i Season_App_Store.mobileprovision` |

---

## How CI Signing Works

`xcodebuild -exportArchive` cannot sign on headless CI (requires Xcode Accounts). Our workflow bypasses this:

```
xcodegen generate → SPM resolve → archive (no signing)
    → security import cert + profile
    → codesign --force --sign --entitlements
    → zip Payload/ → SeasonApp.ipa
    → xcrun altool --upload-app --apiKey
```

---

## iOS TestFlight

1. GitHub → **Actions** → **iOS Build** → **Run workflow**
2. [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → TestFlight → select build
3. Add testers → they install via TestFlight app

---

## Android Play Store

1. Google Play Console → Internal Testing → upload AAB
2. Add testers by email → install via Google Play link

---

## Rendering / Server

| Secret | Where |
|--------|-------|
| `GOOGLE_CLIENT_ID` / `SECRET` | Render env vars |
| `APPLE_CLIENT_ID` / `TEAM_ID` / `KEY_ID` / `PRIVATE_KEY` | Render env vars |
| `RESEND_API_KEY` | Render env vars |
| `SENTRY_DSN` | Render env vars |

---

## Developing on Older Machines

| What | How |
|------|-----|
| Hotwire Native can't compile locally (needs Xcode 15+) | Use CI (`macos-latest` runner) |
| iOS simulator testing | Plain WKWebView + `localhost:3000` via Xcode 14.2 |
| Android | Android Studio 2023.1.1 (last version for macOS 12) |
| Rails | `rbenv` Ruby 3.4.7 |
| Cross-platform testing | E2E Playwright tests against `localhost:3000` |

---

## Key Links

| Resource | URL |
|----------|-----|
| Apple Developer Portal | https://developer.apple.com/account |
| App Store Connect | https://appstoreconnect.apple.com |
| Google Play Console | https://play.google.com/console |
| Hotwire Native iOS | https://github.com/hotwired/hotwire-native-ios |
| Season Render URL | https://seasonv2.onrender.com |
| iOS project | `ios/SeasonApp/` |
| Android project | `android/` |
| CI workflow | `.github/workflows/ios.yml` |
| Pre-push hook | `scripts/pre-push` |
| E2E tests | `tests/app/`, `tests/auth/` |
