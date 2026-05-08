# App Store & Play Store — Deployment Setup Guide

**Last updated:** 2026-05-08  
**App:** Season (Hotwire Native wrapper around the Rails PWA)  
**Strategy:** The web app runs on Render. iOS and Android are thin native shells using Hotwire Native that load the web app inside a `WKWebView` / `WebView`.

---

## Before You Start — What You Need

| Item | iOS | Android |
|------|-----|---------|
| Developer account | Apple Developer ($99/yr) | Google Play Console ($25 one-time) |
| Computer | Mac with Xcode 15+ | Mac or Windows with Android Studio |
| App URL | `https://seasonv2.onrender.com` | same |
| Time to create account | 24–48 hrs (Apple review) | ~1 hr (instant) |

---

## Part 1 — Apple App Store (iOS)

### Step 1 — Create Apple Developer Account

1. Go to [developer.apple.com](https://developer.apple.com)
2. Click **Account** → sign in with your Apple ID (or create one)
3. Click **Join the Apple Developer Program**
4. Choose **Individual** (or **Organization** if registering as a company)
5. Pay the **$99/year** fee
6. Wait for confirmation email — Apple reviews new accounts in **24–48 hours**
7. Once approved, you'll see a full dashboard at [developer.apple.com/account](https://developer.apple.com/account)

> **Tip:** Use the same Apple ID you'll use for Xcode. Don't create a separate account.

---

### Step 2 — Register the App in App Store Connect

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Click **Apps** → **+** → **New App**
3. Fill in:
   - **Platform:** iOS
   - **Name:** Season
   - **Primary Language:** English
   - **Bundle ID:** `com.seasonapp.ios` (must match Xcode project — create as a new explicit App ID first at developer.apple.com → Identifiers)
   - **SKU:** `season-ios-v1` (any unique identifier)
4. Click **Create**

---

### Step 3 — Set Up App ID in Apple Developer Portal

1. Go to [developer.apple.com](https://developer.apple.com) → **Certificates, Identifiers & Profiles**
2. Click **Identifiers** → **+**
3. Choose **App IDs** → **App** → Continue
4. Fill in:
   - **Description:** Season
   - **Bundle ID:** Explicit → `com.seasonapp.ios`
5. Under **Capabilities**, enable:
   - ✅ Push Notifications (for reminders)
   - ✅ Sign In with Apple (required if using Apple OAuth)
6. Click **Register**

---

### Step 4 — Build the iOS App (Hotwire Native)

1. Install [Xcode](https://developer.apple.com/xcode/) from the Mac App Store (free)
2. Create a new Xcode project:
   - **Template:** App (iOS)
   - **Bundle Identifier:** `com.seasonapp.ios`
3. Add the Hotwire Native package:
   - In Xcode: **File → Add Package Dependencies**
   - URL: `https://github.com/hotwired/hotwire-native-ios`
   - Version: latest stable
4. Replace the default `ViewController.swift` with:

```swift
import UIKit
import HotwireNative

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let navigator = Navigator()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigator.rootViewController
        window?.makeKeyAndVisible()
        navigator.route(URL(string: "https://seasonv2.onrender.com")!)
    }
}
```

5. Set the app icon and splash screen (export from Figma — 1024×1024 PNG for the icon)
6. In Xcode: **Product → Archive** to build a release version
7. In the Organizer window: **Distribute App → App Store Connect → Upload**

---

### Step 5 — Submit for Review

1. Back in [appstoreconnect.apple.com](https://appstoreconnect.apple.com), go to your Season app
2. Fill in the **App Information** tab:
   - Category: **Health & Fitness**
   - Age Rating: 4+
3. Under **Pricing and Availability**: Free, all territories
4. Under **App Privacy**: declare data types (see `docs/userdata.md`)
5. Click **Add for Review** → **Submit to App Review**
6. Apple review takes **1–3 days** for first submission

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
| Developer account created | ⬜ | ⬜ |
| App registered in console | ⬜ | ⬜ |
| Xcode / Android Studio project created | ⬜ | ⬜ |
| Hotwire Native integrated | ⬜ | ⬜ |
| App icon + splash screen added | ⬜ | ⬜ |
| Store listing filled in | ⬜ | ⬜ |
| First build uploaded | ⬜ | ⬜ |
| Submitted for review | ⬜ | ⬜ |
| Approved & live | ⬜ | ⬜ |

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
| Privacy data declarations | docs/userdata.md |
