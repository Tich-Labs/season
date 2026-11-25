# App Store & Play Store — Deployment Setup Guide

**Last updated:** 2026-11-24
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
| CI workflow | ✅ `xcode-27` runner → archive → manual sign → IPA artifact (manual Transporter upload) | ✅ builds → signs → uploads to Play track (requires secrets below) |
| Local release signing | ✅ Xcode export → Transporter | ✅ Gradle auto-signs when `android/keystore.properties` exists |
| Pre-push hook | ✅ (rubocop + erb_lint + standard) | N/A |
| E2E tests | ✅ 32 Playwright smoke tests | N/A |
| Manual codesign (headless CI) | ✅ dist cert + provisioning profile | ✅ `r0adkll/sign-android-release` (CI only) |
| Bundle ID | `com.onrender.seasonv2.rubynative` | `com.onrender.seasonv2.rubynative` |

---

## iOS GitHub Secrets (9 required)

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

## How iOS CI Signing Works

`xcodebuild -exportArchive` is avoided on headless CI. The workflow creates an unsigned archive, signs the app bundle manually, and publishes the IPA as an artifact:

```
xcode-27 runner (iOS 27 SDK) → SPM resolve → xcodebuild archive (no signing)
    → security import cert + profile
    → codesign --force --sign --entitlements
    → zip Payload/ → SeasonApp.ipa artifact
    → download artifact → Transporter → TestFlight
```

---

## iOS TestFlight

1. Build locally (`ios/SeasonApp/build/SeasonApp.ipa`) or download the IPA artifact from GitHub → **Actions** → **iOS Build**.
2. Open **Transporter**, sign in with the Apple ID, and drag in `SeasonApp.ipa`.
3. [App Store Connect](https://appstoreconnect.apple.com) → TestFlight → select the processed build.
4. Add testers → they install via the TestFlight app.

Bump `CURRENT_PROJECT_VERSION` before each new archive; App Store Connect rejects duplicate build numbers.

Starting April 2027, App Store Connect requires iOS/iPadOS apps to be built with the iOS 27 SDK. CI uses the `xcode-27` runner, so downloaded IPA artifacts meet that rule. A local Xcode 27 build requires macOS 26.6 or later; this repo's project deployment target (`IPHONEOS_DEPLOYMENT_TARGET = 17.2`) already satisfies the separate iOS 15 minimum target rule. An ITMS-90725 message before that date is a warning, not a rejection, if delivery succeeded.

---

## Android Play Store

Package: `com.onrender.seasonv2.rubynative`. Release AABs point at `https://seasonv2.onrender.com`.

### Local signed AAB (manual, Transporter-style)

`./gradlew :app:bundleRelease` signs automatically when `android/keystore.properties` exists. The file is gitignored and never committed. `storeFile` paths are relative to `android/`, so the repo-root keystore is `../season-upload-key.jks`.

Create `android/keystore.properties`:

```properties
storeFile=../season-upload-key.jks
storePassword=<keystore password>
keyAlias=season-upload
keyPassword=<key password>
```

Environment variables can be used instead of the file: `ANDROID_KEYSTORE_FILE`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`. File values win. If none are set, the AAB is built unsigned (the CI path).

Build and verify:

```bash
cd android
./gradlew :app:bundleRelease -PciVersionCode=102 -PciVersionName=1.0.102
jarsigner -verify app/build/outputs/bundle/release/app-release.aab
```

`jar verified` means the AAB is signed. Bump `ciVersionCode` for every Play upload.

Upload manually:

1. Google Play Console → **Testing** → **Internal testing** (or **Closed testing**).
2. **Create release** → upload `android/app/build/outputs/bundle/release/app-release.aab`.
3. Add release notes → **Review** → **Roll out** → add testers via the **Testers** tab.

Before the first upload from a new machine, confirm **Setup → App integrity → Upload key certificate** SHA-256 matches `season-upload_certificate.pem` (`E3:52:3C:60:...:C7`). Do not rotate the app signing key.

### Android CI (optional)

- Workflow: `.github/workflows/android.yml`, triggered by `v*` tags or manual dispatch.
- Build: unsigned AAB via `./gradlew :app:bundleRelease`; CI does not use `android/keystore.properties`.
- Versioning: `versionCode = github.run_number`, `versionName = 1.0.<run_number>`.
- Signing: `r0adkll/sign-android-release@v1` signs the AAB with the upload keystore from secrets.
- Delivery: `r0adkll/upload-google-play@v1` uploads to the configured track.

Do not set the Gradle signing env vars in the CI job while `r0adkll/sign-android-release` is enabled; that would sign twice.

Required GitHub secrets:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
- `GOOGLE_PLAY_PACKAGE_NAME` (optional, defaults to `com.onrender.seasonv2.rubynative`)
- `GOOGLE_PLAY_TRACK` (optional, defaults to `internal`)

### Upload key reset (when old keystore is missing)

If you no longer have the keystore used for previous Android uploads, reset the
**upload key** in Play Console and switch CI to a new keystore.

Play Console navigation can vary by account. For this app, use:

1. Open app: `Season V2` (`com.onrender.seasonv2.rubynative`)
2. **Protected by Google Play**
3. **Google Play Store Protection**
4. **Manage Play App signature**
5. On the App Signing page, scroll to **Upload key certificate**
6. Click **Request upload key reset** (or equivalent upload-key reset action)

> Important: do not rotate the **App signing key** unless absolutely necessary.
> The normal recovery flow is rotating only the **Upload key**.

Generate a new upload keystore locally:

```bash
keytool -genkeypair \
  -v \
  -keystore season-upload-key.jks \
  -alias season-upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

Export the certificate Play asks for:

```bash
keytool -export -rfc \
  -keystore season-upload-key.jks \
  -alias season-upload \
  -file season-upload_certificate.pem
```

After Google approves the reset, add/update GitHub secrets:

```bash
base64 -i season-upload-key.jks | pbcopy
```

- `ANDROID_KEYSTORE_BASE64` = base64 output
- `ANDROID_KEYSTORE_PASSWORD` = keystore password
- `ANDROID_KEY_ALIAS` = `season-upload`
- `ANDROID_KEY_PASSWORD` = alias key password
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` = service-account JSON
- `GOOGLE_PLAY_PACKAGE_NAME` = `com.onrender.seasonv2.rubynative`
- `GOOGLE_PLAY_TRACK` = `internal` (or preferred track)

For local builds, use the same alias and passwords in `android/keystore.properties`.

---

## Testing (Beta — Test-Invite Setup)

Setup required **once** in each store console before testers can be added or the automation jobs can run. The app code then hands new signups to these tracks:

| Platform | Track | Invite method | Automation |
|----------|-------|---------------|------------|
| iOS | External Testing group | Apple emails each tester (TestFlight) | Background job adds email + fires invitation via App Store Connect API |
| Android | Closed testing | Google emails each tester | Background job adds email via Google Play Developer API |

### iOS — App Store Connect (create the External Testing group)

1. **App Store Connect → My Apps → Season → TestFlight → External Testing**.
2. Click **"+" → New Group**, name it e.g. `Season Beta Testers`.
3. Attach a build to the group (builds arrive from the iOS CI workflow's `xcrun altool --upload-app`).
4. Verify the App Store Connect **API key** used in CI has the **App Manager** role and includes this app — the invitation endpoint needs permission to manage beta testers, not just upload builds. (Key created under **Users and Access → Integrations → API Keys**, same place as `APPSTORE_KEY_ID` / `APPSTORE_ISSUER_ID`.)
5. Save the group ID (shown in the URL when the group is open) — the automation job targets it.

Once the group exists, the background job adds each new iOS tester's email to the group and triggers the invitation (Apple sends the email). API endpoints: `POST /v1/betaTesters` then `POST /v1/betaTesterInvitations`.

### Android — Google Play Console (create the Closed testing track + service account)

1. **Play Console → Season → Testing → Closed testing**, create a track (e.g. name it `beta`), upload an AAB, and **publish** it.
2. Create a **service account** in Google Cloud: **APIs & Services → Credentials → Create credentials → Service account**, download the JSON key.
3. In **Play Console → Users and permissions**, invite that service account with **Manage testers** (or higher) permission.
4. Enable the **Google Play Android Developer API** for the same Google Cloud project.
5. Put the service-account JSON into `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` (Render env var).

The background job then calls `POST /androidpublisher/v3/applications/{package}/testers/{track}` to add each new Android tester; Google emails the invite.

### Implementation status

The app side is wired: `InviteBetaTesterJob` invites both platforms —
`AppStoreConnectService` for iOS and `GooglePlayClosedTestingService` for
Android.

**Render env vars required** (all `sync: false` in `render.yaml`):

| Env var | Value |
|---------|-------|
| `APPSTORE_KEY_ID` | App Store Connect API key ID |
| `APPSTORE_ISSUER_ID` | Issuer ID (same API keys page) |
| `APPSTORE_KEY_BASE64` | `base64 -i ~/Downloads/AuthKey_XXX.p8` |
| `APPSTORE_APP_ID` | Apple's numeric app resource ID |
| `APPSTORE_BETA_GROUP_ID` | External testing group ID (from step 5 above) |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Full service-account JSON from Google Cloud |
| `GOOGLE_PLAY_PACKAGE_NAME` | `com.onrender.seasonv2.rubynative` |
| `GOOGLE_PLAY_TRACK` | Closed-testing track name (e.g. `beta`) |

Until these are set, the corresponding job no-ops (testers stay `registered`
for a manual retry).

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
| Android signing config | `android/app/build.gradle.kts` |
| CI workflow | `.github/workflows/ios.yml` |
| Android workflow | `.github/workflows/android.yml` |
| Pre-push hook | `scripts/pre-push` |
| E2E tests | `tests/app/`, `tests/auth/` |
