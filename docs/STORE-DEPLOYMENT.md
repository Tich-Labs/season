# App Store & Play Store — Deployment Setup Guide

**Last updated:** 2026-05-22
**App:** Season (Hotwire Native wrappers around the Rails PWA)
**Architecture:** The web app runs on Render at `https://seasonv2.onrender.com`. iOS and Android use **Hotwire Native** — native tab bars replace the web burger menu. The web app handles all content (calendar, tracking, symptoms, daily view). External URLs open in the system browser.

---

## What's Already Done (in code — no account needed)

| Item | iOS | Android |
|------|-----|---------|
| Hotwire Native integrated | ✅ (`hotwire-native-ios` via SPM) | ✅ (`hotwire-native-android` via Gradle) |
| Native tab bar (3 tabs) | ✅ Calendar / Tracking / Settings | ✅ Calendar / Tracking / Settings |
| Auth token flow | ✅ `X-Turbo-Native-Token` header | ✅ Same token flow |
| Path configuration | ✅ `/configurations/ios_v1.json` | ✅ `/configurations/android_v1.json` |
| Web nav hidden in native | ✅ Burger menu + FAB hidden, tab bar replaces | ✅ Same |
| App icon | ✅ All sizes | ❌ (needs mipmap resources) |
| Launch screen | ✅ Storyboard | ❌ |
| PrivacyInfo.xcprivacy | ✅ | N/A |
| CI workflow | ✅ GitHub Actions (xcodegen → SPM → archive → sign → upload) | ❌ |
| Bundle ID | `com.season-app.ios` | `com.seasonapp.android` |

**What's left is account/console work + first build** — no code changes needed.

---

## Part 1 — Apple App Store (iOS)

### Step 1 — Create Apple Developer Account ✅ DONE

### Step 2 — Register the App in App Store Connect

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. **Apps** → **+** → New App → Bundle ID: `com.season-app.ios`

### Step 3 — App Store Connect API Key

1. App Store Connect → **Users and Access** → **Integrations** → **App Store Connect API** → **+**
2. Name "GitHub Actions", Access: **App Manager**
3. Save the **Key ID**, **Issuer ID**, and download the `.p8` file

### Step 4 — GitHub Secrets

All 6 secrets at GitHub → Settings → Secrets → Actions:

| Secret | Value |
|--------|-------|
| `DEVELOPMENT_TEAM` | `CH4G9T6ZHP` |
| `APPLE_ID` | Developer Apple ID |
| `APP_SPECIFIC_PASSWORD` | From appleid.apple.com |
| `APPSTORE_KEY_ID` | From API Key (Step 3) |
| `APPSTORE_ISSUER_ID` | From API Key (Step 3) |
| `APPSTORE_KEY_BASE64` | `base64 AuthKey_XXX.p8` output |
| `DIST_CERT_BASE64` | Distribution certificate p12 (base64) |
| `DIST_CERT_PASSWORD` | p12 password |

### Step 5 — Run CI

GitHub → **Actions** → **iOS Build** → **Run workflow**. Cloud Mac: xcodegen → SPM resolve → archive → sign → upload to TestFlight.

### Step 6 — TestFlight

App Store Connect → **TestFlight** → select build → add testers.

---

## Part 2 — Google Play Store (Android)

### Step 1 — Create Google Play Developer Account

1. Go to [play.google.com/console](https://play.google.com/console)
2. Pay **$25 one-time** fee
3. Account activated immediately

### Step 2 — Create App in Play Console

Play Console → **Create App** → Name "Season" → Free → package `com.seasonapp.android`

### Step 3 — Build (Android Studio)

```bash
# Open android/ in Android Studio
# Sync Gradle → Build → Generate Signed Bundle → Android App Bundle (AAB)
# Create keystore (save securely — never lose it)
```

### Step 4 — Internal Testing (TestFlight equivalent)

1. Play Console → **Testing** → **Internal Testing** → upload AAB
2. Add testers by email
3. Testers install via Google Play link

---

## Status Tracker

| Task | iOS | Android |
|------|-----|---------|
| Developer account created | ✅ | ❌ |
| Hotwire Native integrated | ✅ | ✅ |
| Native tab bar | ✅ Calendar/Tracking/Settings | ✅ Calendar/Tracking/Settings |
| App registered in console | ❌ | ❌ |
| App icon | ✅ | ❌ |
| Path configuration | ✅ | ✅ |
| CI workflow | ✅ | ❌ |
| API Key configured | ⚠️ (needs regen) | N/A |
| GitHub secrets set | ⚠️ (needs API key update) | N/A |
| First build | ❌ | ❌ |
| TestFlight / Internal Testing | ❌ | ❌ |

---

## Key Links

| Resource | URL |
|----------|-----|
| Apple Developer Portal | https://developer.apple.com/account |
| App Store Connect | https://appstoreconnect.apple.com |
| Google Play Console | https://play.google.com/console |
| Hotwire Native iOS | https://github.com/hotwired/hotwire-native-ios |
| Hotwire Native Android | https://github.com/hotwired/hotwire-native-android |
| Season Render URL | https://seasonv2.onrender.com |
| iOS project | `ios/SeasonApp/` |
| Android project | `android/` |
| CI iOS workflow | `.github/workflows/ios.yml` |
