# App Store & Play Store — Deployment Setup Guide

**Last updated:** 2026-05-26
**App:** Season (Hotwire Native wrappers around the Rails PWA)

---

## Architecture

The web app runs on Render at `https://seasonv2.onrender.com`. iOS and Android use Hotwire Native — native tab bars (Calendar / Tracking / Settings) replace the web burger menu. All content is server-rendered HTML.

---

## Machine Requirements

| Task | Minimum | What We Have |
|------|---------|-------------|
| **Local iOS dev** | macOS 13+ with Xcode 15+ | macOS 12 with Xcode 14.2 ❌ |
| **Local iOS build** | macOS 13+ (hotwire-native-ios needs Swift 5.9+) | Can't compile ❌ |
| **CI iOS build** | GitHub Actions `macos-latest` (free) | Xcode 16.4, works ✅ |
| **Local Android dev** | Android Studio 2023.1+ (any OS) | Works on macOS 12 ✅ |
| **Rails dev** | Ruby 3.4, PostgreSQL | Works ✅ |

**Key takeaway:** A 2015 MacBook Pro (macOS 12) CAN do Rails + Android dev + plain WKWebView iOS testing. For Hotwire Native iOS builds, use CI (free GitHub Actions cloud Mac).

---

## What's Already Done (in code)

| Item | iOS | Android |
|------|-----|---------|
| Hotwire Native integrated | ✅ (`hotwire-native-ios` via SPM) | ✅ (`hotwire-native-android` via Gradle) |
| Native tab bar (3 tabs) | ✅ Calendar / Tracking / Settings | ✅ Calendar / Tracking / Settings |
| Auth token flow | ✅ `X-Turbo-Native-Token` header | ✅ Same |
| Path configuration | ✅ `/configurations/ios_v1.json` | ✅ `/configurations/android_v1.json` |
| Web nav hidden in native | ✅ Burger + FAB hidden, tab bar replaces | ✅ Same |
| App icon (all sizes) | ✅ | ❌ |
| Launch screen | ✅ Storyboard | ❌ |
| PrivacyInfo.xcprivacy | ✅ | N/A |
| CI workflow | ✅ (archive → manual sign → IPA → upload) | ❌ |
| Bundle ID | `com.season-app.ios` | `com.seasonapp.android` |

---

## Part 1 — Apple App Store (iOS)

### Secrets Setup (one-time, 7 secrets)

All set at GitHub → repo → **Settings** → **Secrets and variables** → **Actions**:

#### Developer Account Secrets

| Secret | Source | Notes |
|--------|--------|-------|
| `DEVELOPMENT_TEAM` | Apple Developer → Membership | `28NDQR5JC4` (Shanel Chien individual account) |
| `APPLE_ID` | Developer Apple ID | `shanel@season.vision` |
| `APP_SPECIFIC_PASSWORD` | appleid.apple.com → App-Specific Passwords | Required for altool upload |

#### App Store Connect API Key

| Secret | Source |
|--------|--------|
| `APPSTORE_KEY_ID` | App Store Connect → Users & Access → Integrations → API Key ID |
| `APPSTORE_ISSUER_ID` | Same page, Issuer ID at top |
| `APPSTORE_KEY_BASE64` | `base64 -i ~/Downloads/AuthKey_XXX.p8` |

**API key setup steps:**
1. [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → Users and Access → Integrations → App Store Connect API
2. Click **+** → Name "GitHub Actions" → Access: **App Manager**
3. Copy the **Issuer ID** (top of page) and **Key ID** (next to key name)
4. Download the `.p8` file — you can only download it once
5. Base64 encode it: `base64 -i ~/Downloads/AuthKey_XXX.p8`

#### Signing Certificate + Provisioning Profile

| Secret | Source |
|--------|--------|
| `DIST_CERT_BASE64` | Generated from distribution certificate .p12 |
| `DIST_CERT_PASSWORD` | Password used when creating the .p12 |
| `PROVISIONING_PROFILE_BASE64` | `base64 -i ~/Downloads/Season_App_Store.mobileprovision` |

**Creating the distribution certificate (one-time):**
```bash
# 1. Generate private key + CSR
openssl genrsa -out season_dist_key.pem 2048
openssl req -new -key season_dist_key.pem -out season_dist.csr \
  -subj "/emailAddress=shanel@season.vision/CN=Season Distribution"

# 2. Upload season_dist.csr at developer.apple.com → Certificates → + → Apple Distribution
# 3. Download distribution.cer
# 4. Convert to .p12
openssl x509 -in ~/Downloads/distribution.cer -inform DER -out season_cert.pem
openssl pkcs12 -export -inkey season_dist_key.pem -in season_cert.pem \
  -out season_dist.p12 -passout pass:season123

# 5. Base64 for CI
base64 season_dist.p12  # → DIST_CERT_BASE64
```

**Creating the provisioning profile:**
1. [developer.apple.com/account](https://developer.apple.com/account) → **Profiles** → **+**
2. **App Store Connect** → Continue
3. Select **com.season-app.ios** → Continue
4. Select the distribution certificate (Shanel Chien) → Continue
5. Name: "Season App Store" → Generate → Download
6. `base64 -i ~/Downloads/Season_App_Store.mobileprovision` → `PROVISIONING_PROFILE_BASE64`

### How CI Build Works

```
Generate Xcode project  (xcodegen + SPM resolve)
        ↓
Archive                 (xcodebuild, CODE_SIGNING_REQUIRED=NO)
        ↓
Import cert + profile   (security import + keychain)
        ↓
Manual codesign         (/usr/bin/codesign --force --sign)
        ↓
Create IPA              (zip Payload/)
        ↓
Upload to TestFlight    (xcrun altool --apiKey --apiIssuer)
```

**Why manual signing:** `xcodebuild -exportArchive` with `method: app-store-connect` always contacts Apple servers — impossible on headless CI without Xcode Accounts. Manual `codesign` + `altool` upload bypasses this.

### Register the App in App Store Connect

1. [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **Apps** → **+** → New App
2. Platform: iOS, Name: Season, Bundle ID: `com.season-app.ios`, SKU: `season-ios-v1`

### Run

GitHub → **Actions** → **iOS Build** → **Run workflow**. The IPA auto-uploads to App Store Connect. Then **TestFlight** → select build → add testers.

---

## Part 2 — Google Play Store (Android)

### Setup

| Step | Details |
|------|---------|
| Developer account | [play.google.com/console](https://play.google.com/console) → $25 one-time |
| Register app | Package: `com.seasonapp.android`, Free |
| Build | Open `android/` in Android Studio → Gradle sync → Build → Generate Signed Bundle → AAB |
| Test | Internal Testing track — add testers by email, install via Google Play link |

### Android CI (future)

Same pattern as iOS: GitHub Actions with `ubuntu-latest` → Gradle build → sign with keystore → upload via Google Play Publishing API.

---

## Developing on Older Machines

| What | How |
|------|-----|
| **Hotwire Native iOS can't compile locally** | Use GitHub Actions `macos-latest` (free tier: 2000 min/month) |
| **iOS testing** | Build with plain WKWebView locally (works on Xcode 14.2), use simulator |
| **Android** | Android Studio 2023.1.1 (Hedgehog) — last version for macOS 12 |
| **Rails** | Works fine — `rbenv` with Ruby 3.4.7 |
| **Cross-platform testing** | Web app at `localhost:3000` or `seasonv2.onrender.com` on any browser |

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
| CI workflow | `.github/workflows/ios.yml` |
