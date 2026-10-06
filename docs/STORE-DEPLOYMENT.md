# App Store & Play Store — Deployment Setup Guide

**Last updated:** 2026-10-01
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
| Bundle ID | `com.onrender.seasonv2.rubynative` | `com.seasonapp.android` |

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
| `GOOGLE_PLAY_PACKAGE_NAME` | `com.seasonapp.android` |
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
| CI workflow | `.github/workflows/ios.yml` |
| Pre-push hook | `scripts/pre-push` |
| E2E tests | `tests/app/`, `tests/auth/` |
