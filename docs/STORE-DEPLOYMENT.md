# App Store & Play Store — Deployment Setup Guide

**Last updated:** 2026-05-22
**App:** Season (thin WKWebView wrapper around the Rails PWA)
**Strategy:** The web app runs on Render at `https://seasonv2.onrender.com` (custom domain `season.vision` planned). iOS and Android are thin native shells using plain WKWebView / WebView that load the web app. The web app handles all navigation (burger menu, FAB, calendar icon). External URLs (OAuth providers) open in the system browser.

---

## What's Already Done (in code — no account needed)

| Item | iOS | Android |
|------|-----|---------|
| Xcode / Android Studio project | ✅ (`ios/SeasonApp/`) | ❌ |
| WKWebView shell | ✅ (plain WKWebView, no dependencies) | ❌ |
| Auth token flow | ✅ (X-Turbo-Native-Token header) | ❌ |
| Header + burger menu visible in native | ✅ | N/A |
| FAB + quick actions visible in native | ✅ | N/A |
| External URLs → system browser | ✅ (WKNavigationDelegate) | ❌ |
| App icon (all sizes) | ✅ | ❌ |
| Launch screen (storyboard) | ✅ | ❌ |
| PrivacyInfo.xcprivacy | ✅ | ❌ |
| ITSAppUsesNonExemptEncryption | ✅ | ❌ |
| Scene manifest in Info.plist | ✅ | ❌ |
| CI workflow (xcodegen + xcodebuild) | ✅ | ❌ |
| Bundle ID | `com.season-app.ios` | `com.seasonapp.android` (planned) |

**What's left is entirely account/console work** — no code changes needed.

---

## Before You Start — What You Need

| Item | iOS | Android |
|------|-----|---------|
| Developer account | Apple Developer ($99/yr) ✅ | Google Play Console ($25 one-time) |
| App URL | `https://seasonv2.onrender.com` (custom domain `season.vision` planned) | same |
| Time to create account | 24–48 hrs (Apple reviews new enrollments) | ~1 hr (instant) |
| App Store name | ⚠️ "Season" may be taken — have backups ready | same check |
| CI signing | App Store Connect API Key (free, set up once) | N/A |

---

## Part 1 — Apple App Store (iOS)

### Step 1 — Create Apple Developer Account ✅ DONE

Already completed. Apple Developer account active — team ID `CH4G9T6ZHP`.

---

### Step 2 — Register the App in App Store Connect

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Sign in with the developer Apple ID
3. Click **Apps** → **+** (top left) → **New App**
4. Fill in:
   - **Platform:** iOS
   - **Name:** Season (⚠️ if "Season" is taken, try "Season App", "Season Tracker", or "Season Cycle")
   - **Primary Language:** English
   - **Bundle ID:** `com.season-app.ios`
   - **SKU:** `season-ios-v1`
   - **User Access:** Full Access
5. Click **Create**

---

### Step 3 — Set Up App ID & Capabilities

1. Go to [developer.apple.com/account](https://developer.apple.com/account) → **Certificates, Identifiers & Profiles**
2. Click **Identifiers** → **+**
3. Choose **App IDs** → **App** → Continue
4. Fill in:
   - **Description:** Season
   - **Bundle ID:** Explicit → `com.season-app.ios`
5. Under **Capabilities**, enable:
   - ✅ **Push Notifications** — for cycle/period reminder push notifications
   - ✅ **Sign In with Apple** — required if using Apple OAuth (future)
6. Click **Register**

---

### Step 4 — App Store Connect API Key (for CI)

Required for GitHub Actions to sign and upload builds. One-time setup.

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **Users and Access** → **Integrations** → **App Store Connect API**
2. Click **+** → name it "GitHub Actions" → Access: **Developer**
3. Click **Generate** → copy and save:
   - **Issuer ID** (e.g., `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)
   - **Key ID** (e.g., `ABC123XYZ`)
4. Download the `.p8` key file — **you can only download it once**
5. Add as GitHub secrets (Settings → Secrets → Actions):
   - `APPSTORE_KEY_ID` = the Key ID
   - `APPSTORE_ISSUER_ID` = the Issuer ID
   - `APPSTORE_KEY_BASE64` = run `base64 -i ~/Downloads/AuthKey_XXXX.p8` and paste the output

---

### Step 5 — Set GitHub Secrets

All 5 secrets needed in GitHub → Settings → Secrets → Actions:

| Secret | Value | Source |
|--------|-------|--------|
| `DEVELOPMENT_TEAM` | `CH4G9T6ZHP` | Apple Developer account |
| `APPLE_ID` | Developer Apple ID email | Apple ID |
| `APP_SPECIFIC_PASSWORD` | App-specific password | [appleid.apple.com](https://appleid.apple.com) → Sign-In & Security |
| `APPSTORE_KEY_ID` | Key ID from Step 4 | App Store Connect API |
| `APPSTORE_ISSUER_ID` | Issuer ID from Step 4 | App Store Connect API |
| `APPSTORE_KEY_BASE64` | Base64 encoded .p8 file | Step 4 |

---

### Step 6 — Run iOS Build via CI

GitHub Actions handles the build on a cloud Mac (latest Xcode, no local setup needed).

1. Go to GitHub → **Actions** → **iOS Build** → **Run workflow**
2. The workflow:
   - Installs xcodegen → generates `.xcodeproj` from `project.yml`
   - Archives the app (no signing, just compilation)
   - Exports IPA with App Store signing
   - Uploads to App Store Connect
3. After success (~10 min), the build appears in [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **TestFlight**

---

### Step 7 — TestFlight

1. In App Store Connect → **TestFlight** → **iOS Builds** — the uploaded build appears
2. Click the build → **Internal Testing** → add testers (up to 100, no review needed)
3. Testers install the TestFlight app from the App Store and redeem the invitation

---

### Step 8 — Submit for Review (after TestFlight)

1. Go back to [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → your Season app
2. Fill in metadata:

**App Information:**
- Category: **Health & Fitness**
- Age Rating: 4+

**Pricing and Availability:**
- Free, all territories

**App Privacy:**
- Declare data types (see `docs/userdata.md`):
  - Health & Fitness (cycle data, symptoms) — linked to identity
  - Contact Info (email, name) — linked to identity
  - User Content (symptom logs, notes) — linked to identity
  - Diagnostics (crash data via Sentry) — not linked

**App Review Information:**
- Sign-in required: Yes
- Contact info: `info@season.vision`
- Notes for reviewer: "This app tracks menstrual cycles. All health data is self-reported by the user. No HealthKit integration. The app is a thin WKWebView wrapper around a PWA."

3. Click **Add for Review** → **Submit to App Review**
4. Apple review takes **1–3 days** for first submissions

---

## Part 2 — Google Play Store (Android)

### Step 1 — Create Google Play Developer Account

1. Go to [play.google.com/console](https://play.google.com/console)
2. Sign in with a **Google account**
3. Click **Get Started**
4. Choose **Individual** or **Organization**
5. Pay the **$25 one-time** registration fee
6. Account is activated **immediately** after payment

---

### Step 2 — Create the App in Play Console

1. In Play Console, click **Create App**
2. Fill in:
   - **App name:** Season
   - **Default language:** English
   - **App or Game:** App
   - **Free or Paid:** Free
3. Accept the declarations and click **Create App**

---

### Step 3 — Build the Android App (WebView wrapper)

✅ **Scaffolded** at `android/`. Thin `WebView` wrapper mirroring iOS — 1 Kotlin file, standard AndroidX dependencies, no native UI.

1. Install [Android Studio](https://developer.android.com/studio) (free)
2. Open `android/` as the project root
3. Let Gradle sync (first time downloads Android SDK + dependencies)
4. **Build → Generate Signed Bundle / APK → Android App Bundle (AAB)**
5. Create a keystore (keep this file safe — you can never lose it)

**Project structure:**

| File | Purpose |
|------|---------|
| `app/src/main/java/.../MainActivity.kt` | WebView + external URL routing |
| `app/src/main/AndroidManifest.xml` | INTERNET permission, activity declaration |
| `app/build.gradle.kts` | Android SDK 34, Kotlin 2.0, AppCompat |
| `build.gradle.kts` | Root project plugins |
| `settings.gradle.kts` | Module includes |
| `gradle.properties` | JVM heap, AndroidX flag |

---

### Step 6 — Internal Testing (Android TestFlight equivalent)

Google Play Console has **Internal Testing** — identical to TestFlight:

1. Play Console → **Testing** → **Internal Testing** → **Create new release**
2. Upload the `.aab` file
3. Add testers by email (up to 100, immediate — no review needed)
4. Testers get an email with a Play Store install link
5. App installs via Google Play (not sideloaded)

This is the Android equivalent of TestFlight. Same flow: build → upload → invite testers → they install from the store.

---

### Step 5 — Store Listing

Fill in before submitting (Play Console → **Main store listing**):

| Field | Value |
|-------|-------|
| App name | Season |
| Short description | Track your cycle, understand your body. |
| Category | Health & Fitness |
| Screenshots | Minimum 2 phone screenshots |
| App icon | 512×512 PNG |

---

## Status Tracker

| Task | iOS | Android |
|------|-----|---------|
| Developer account created | ✅ | ❌ |
| App registered in console | ❌ | ❌ |
| Xcode / Android Studio project created | ✅ | ❌ |
| WKWebView / WebView wrapper built | ✅ (plain WKWebView, 2 Swift files) | ✅ (`android/`, 1 Kotlin file) |
| Auth token flow (X-Turbo-Native-Token) | ✅ | ❌ |
| Header/FAB visible in native context | ✅ | N/A |
| External URLs → system browser | ✅ | ❌ |
| App icon + splash screen | ✅ | ❌ |
| PrivacyInfo.xcprivacy | ✅ | ❌ |
| CI workflow setup | ✅ | ❌ |
| App Store Connect API Key | ❌ (needed for CI signing) | N/A |
| GitHub secrets set | ❌ (needs 6 secrets) | ❌ |
| Store listing filled in | ❌ | ❌ |
| First build uploaded | ❌ | ❌ |
| Submitted for review | ❌ | ❌ |
| Approved & live | ❌ | ❌ |

---

## Key Links

| Resource | URL |
|----------|-----|
| Apple Developer Portal | https://developer.apple.com/account |
| App Store Connect | https://appstoreconnect.apple.com |
| Google Play Console | https://play.google.com/console |
| Season Render URL | https://seasonv2.onrender.com |
| Season Source (iOS project) | `ios/SeasonApp/` |
| CI workflow | `.github/workflows/ios.yml` |
| Project config | `ios/SeasonApp/project.yml` |
| Privacy data declarations | `docs/userdata.md` |
| iOS Integration docs | `docs/ios.md` |
