# App Store & Play Store — Deployment Setup Guide

**Last updated:** 2026-05-21
**App:** Season (Turbo Native wrapper around the Rails PWA)
**Strategy:** The web app runs on Render at `https://seasonv2.onrender.com` (custom domain `season.vision` planned). iOS and Android are thin shells using turbo-ios / turbo-android that load the web app in a web view.

---

## What's Already Done (in code — no account needed)

| Item | iOS | Android |
|------|-----|---------|
| Xcode / Android Studio project | ✅ (`ios/SeasonApp/`) | ❌ |
| Turbo Native integrated | ✅ (turbo-ios v8.0.0 via SPM) | ❌ |
| Auth token flow | ✅ (X-Turbo-Native-Token header) | ❌ |
| Header + burger menu visible in native | ✅ (May 21) | ❌ |
| FAB + quick actions visible in native | ✅ (May 21) | ❌ |
| External URLs → Safari | ✅ (SceneDelegate `isInternalURL`) | ❌ |
| Error handling with retry | ✅ (NavigatorDelegate) | ❌ |
| App icon (1024×1024) | ✅ | ❌ |
| Launch screen (storyboard) | ✅ | ❌ |
| PrivacyInfo.xcprivacy | ✅ (May 21) | ❌ |
| ITSAppUsesNonExemptEncryption | ✅ | ❌ |
| Bundle ID | `com.season-app.ios` | `com.seasonapp.android` (planned) |

**What's left is entirely account/console work** — no code changes needed.

---

## Before You Start — What You Need

| Item | iOS | Android |
|------|-----|---------|
| Developer account | Apple Developer ($99/yr) | Google Play Console ($25 one-time) |
| Computer | Mac with Xcode 15+ | Mac or Windows with Android Studio |
| App URL | `https://seasonv2.onrender.com` (custom domain `season.vision` planned) | same |
| Time to create account | 24–48 hrs (Apple reviews new enrollments) | ~1 hr (instant) |
| App Store name | ⚠️ "Season" may be taken — have a backup ready (e.g. "Season App", "Season Tracker") | same check |

---

## Part 1 — Apple App Store (iOS)

### Step 1 — Create Apple Developer Account

This is the first and most important step. Everything else depends on it.

**Prerequisites:**
- An Apple ID (create one at [appleid.apple.com](https://appleid.apple.com) if you don't have one)
- Two-factor authentication enabled on the Apple ID
- A credit/debit card for the $99/year fee
- The Apple ID should match the one you'll sign into Xcode with

**Steps:**

1. Go to [developer.apple.com](https://developer.apple.com)
2. Click **Account** (top right) → sign in with your Apple ID
3. Click **Join the Apple Developer Program**
4. Choose your entity type:
   - **Individual** — easiest. Uses your legal name as the seller name on the App Store.
   - **Organization** — requires a D-U-N-S number (free, but takes 5+ business days to obtain). The company name appears as the seller.
5. Fill in your personal/entity information
6. Pay the **$99/year** fee
7. **Wait.** Apple manually reviews new enrollments. This takes **24–48 hours** (sometimes longer for organizations).
8. You'll receive a confirmation email when approved
9. Once approved, your dashboard is at [developer.apple.com/account](https://developer.apple.com/account)

**Common issues:**
- Organization enrollment requires a D-U-N-S number. Get one free at [dnb.com](https://www.dnb.com/duns-number.html). This adds 5-10 business days.
- If the enrollment is rejected, check that your legal name matches your Apple ID exactly.
- The Apple ID must have two-factor authentication enabled. You cannot enroll without it.

> **Tip:** Use the same Apple ID you'll sign into Xcode with. Don't create a separate account just for the developer program.

---

### Step 2 — Register the App in App Store Connect

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Sign in with your developer Apple ID
3. Click **Apps** → **+** (top left) → **New App**
4. Fill in:
   - **Platform:** iOS
   - **Name:** Season (⚠️ if "Season" is taken, try "Season App", "Season Tracker", or "Season Cycle")
   - **Primary Language:** English
   - **Bundle ID:** `com.season-app.ios` (must match the Xcode project — you'll create this App ID in Step 3)
   - **SKU:** `season-ios-v1` (any unique string, used internally)
   - **User Access:** Full Access
5. Click **Create**

---

### Step 3 — Set Up App ID & Capabilities

1. Go to [developer.apple.com/account](https://developer.apple.com/account) → **Certificates, Identifiers & Profiles**
2. Click **Identifiers** → **+** (top left)
3. Choose **App IDs** → **App** → Continue
4. Fill in:
   - **Description:** Season
   - **Bundle ID:** Explicit → `com.season-app.ios`
5. Under **Capabilities**, enable:
   - ✅ **Push Notifications** — for cycle/period reminder push notifications
   - ✅ **Sign In with Apple** — required if using Apple OAuth (future)
6. Click **Register**

---

### Step 4 — Build & Upload from Xcode

The iOS project already exists at `ios/SeasonApp/`. It uses **XcodeGen** (`project.yml`) and **turbo-ios** via Swift Package Manager.

**One-time setup:**

```bash
# Install XcodeGen (if not already)
brew install xcodegen

# Regenerate the Xcode project from project.yml
cd ios/SeasonApp
xcodegen generate

# Open in Xcode
open SeasonApp.xcodeproj
```

When Xcode opens, it will resolve the turbo-ios SPM package. Once resolved, commit the generated `Package.resolved`:

```bash
git add ios/SeasonApp/SeasonApp.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
git commit -m "Add Package.resolved for turbo-ios SPM dependency"
```

**Every release build:**

1. In Xcode, select **Product → Scheme → SeasonApp** (set to "Any iOS Device", not a simulator)
2. Select **Product → Archive**
3. When the Organizer opens, select the archive → **Distribute App**
4. Choose **App Store Connect** → **Upload**
5. Follow the prompts (Xcode handles code signing automatically with your developer account)

---

### Step 5 — Submit for Review

1. Go back to [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → your Season app
2. Select the uploaded build under **App Store** → **iOS App** → **Build**
3. Fill in the remaining metadata:

**App Information:**
- Category: **Health & Fitness**
- Age Rating: 4+
- Copyright: Your name/company

**Pricing and Availability:**
- Free, all territories

**App Privacy:**
- Declare data types (see `docs/userdata.md` for the full data map):
  - Health & Fitness (cycle data, symptoms) — linked to identity
  - Contact Info (email, name) — linked to identity
  - User Content (symptom logs, notes) — linked to identity
  - Diagnostics (crash data via Sentry) — not linked

**App Review Information:**
- Sign-in required: Yes (provide a demo account or note that reviewers should create one)
- Contact info: `info@season.vision`
- Notes for reviewer: "This app tracks menstrual cycles. All health data is self-reported by the user and stored encrypted. No HealthKit integration."

4. Click **Add for Review** → **Submit to App Review**
5. Apple review takes **1–3 days** for first submissions (cycle tracking apps may get additional scrutiny)

---

### Step 6 — TestFlight (Recommended Before App Store)

Before submitting for full App Store review, use TestFlight for internal testing:

1. In App Store Connect, go to **TestFlight** → **Internal Testing**
2. Add your team (up to 100 internal testers, no review needed)
3. Select the build and start testing
4. Testers install the TestFlight app from the App Store and redeem your invitation

---

## Part 2 — Google Play Store (Android)

### Step 1 — Create Google Play Developer Account

1. Go to [play.google.com/console](https://play.google.com/console)
2. Sign in with a **Google account** (use the company Google account)
3. Click **Get Started**
4. Choose **Individual** or **Organization**
5. Pay the **$25 one-time** registration fee
6. Verify your identity (Google asks for name + address)
7. Account is activated **immediately** after payment

---

### Step 2 — Create the App in Play Console

1. In Play Console, click **Create App**
2. Fill in:
   - **App name:** Season
   - **Default language:** English (United Kingdom) or English (United States)
   - **App or Game:** App
   - **Free or Paid:** Free
3. Accept the declarations and click **Create App**

---

### Step 3 — Build the Android App (Hotwire Native)

1. Install [Android Studio](https://developer.android.com/studio) (free)
2. Create a new project:
   - **Template:** Empty Activity
   - **Package name:** `com.seasonapp.android`
   - **Language:** Kotlin
   - **Min SDK:** API 26 (Android 8.0)
3. Add Hotwire Native to `build.gradle.kts` (app level):

```kotlin
dependencies {
    implementation("dev.hotwire:hotwire-native-android:1.0.0")
}
```

4. Replace `MainActivity.kt` with:

```kotlin
import dev.hotwire.core.turbo.session.TurboSessionNavHostFragment
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Load Season web app in Hotwire Native shell
        // Full setup: https://github.com/hotwired/hotwire-native-android
    }
}
```

> **Note:** Full Hotwire Native Android setup is documented in the [official repo](https://github.com/hotwired/hotwire-native-android). The above is the shell; follow their quickstart for the nav host fragment wiring.

5. In Android Studio: **Build → Generate Signed Bundle / APK**
   - Choose **Android App Bundle** (AAB) — Play Store requires this
   - Create a new keystore (keep this file safe — you can never lose it)
   - Build release AAB

---

### Step 4 — Upload and Publish

1. In Play Console, go to your Season app → **Release** → **Production**
2. Click **Create new release**
3. Upload the `.aab` file
4. Fill in the **Release notes** (what's new)
5. Click **Review release** → **Start rollout to Production**
6. First app review takes **3–7 days**; subsequent updates are faster

---

### Step 5 — Store Listing

Fill in before submitting (Play Console → **Main store listing**):

| Field | Value |
|-------|-------|
| App name | Season |
| Short description | Track your cycle, understand your body. |
| Full description | (see marketing copy) |
| Category | Health & Fitness |
| Screenshots | Minimum 2 phone screenshots (export from Figma) |
| Feature graphic | 1024×500 JPG |
| App icon | 512×512 PNG |

---

## Status Tracker

| Task | iOS | Android |
|------|-----|---------|
| Developer account created | ⚠️ (team ID CH4G9T6ZHP in pbxproj — status unconfirmed) | ❌ |
| App registered in console | ❌ | ❌ |
| Xcode / Android Studio project created | ✅ | ❌ |
| Turbo Native integrated | ✅ (turbo-ios v8.0.0 via SPM) | ❌ |
| Auth token flow (X-Turbo-Native-Token) | ✅ | ❌ |
| Header/FAB visible in native context | ✅ (May 21) | N/A |
| External URLs → system browser | ✅ (May 21) | ❌ |
| App icon + splash screen | ✅ | ❌ |
| PrivacyInfo.xcprivacy | ✅ (May 21) | ❌ |
| ITSAppUsesNonExemptEncryption | ✅ (May 21) | ❌ |
| Package.resolved committed | ⏳ (open Xcode → resolve packages → commit) | ❌ |
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
| Turbo iOS (SPM package) | https://github.com/hotwired/turbo-ios |
| Hotwire Native Android | https://github.com/hotwired/hotwire-native-android |
| Season Render URL | https://seasonv2.onrender.com |
| Season Source (iOS project) | `ios/SeasonApp/` |
| Privacy data declarations | docs/userdata.md |
| iOS Integration docs | docs/ios.md |
