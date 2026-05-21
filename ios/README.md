# Season iOS App

Wrap Season PWA in a native iOS shell using Hotwire Native (turbo-ios v8.0.0 via SPM).

## Prerequisites

```bash
# Check if Xcode is installed
xcode-select -p
# Should return: /Applications/Xcode.app/Contents/Developer

# Install XcodeGen
brew install xcodegen
```

**Install Xcode (if needed):**
1. Open **Mac App Store** → Search "Xcode" → Install (~12GB)
2. Launch Xcode once → Accept license
3. Run: `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`

## Setup

1. **Regenerate project:**
   ```bash
   cd ios/SeasonApp
   xcodegen generate
   open SeasonApp.xcodeproj
   ```

2. **Resolve packages:**
   - Xcode will resolve turbo-ios via SPM on first open
   - Commit the generated `Package.resolved`

3. **Connect iPhone:**
   - Plug in via USB
   - iPhone: Settings → General → About → Trust this Computer
   - Xcode: Window → Devices → Select your device

4. **Configure Team:**
   - Xcode: Project → Signing & Capabilities
   - Team: Select your Apple ID (free tier works for development)
   - Bundle ID: `com.season-app.ios`

5. **Run:**
   - Xcode: Select "SeasonApp" scheme → Your connected iPhone
   - Click **Run (▶️)**

## Architecture

- **Dependency:** `turbo-ios` v8.0.0 via Swift Package Manager (`project.yml`)
- `AppDelegate.swift` — Standard UIApplicationDelegate entry point
- `SceneDelegate.swift` — Turbo Navigator with `VisitableViewController`:
  - Push/replace navigation via `NavigatorDelegate.didProposeVisit`
  - Error handling with retry alert via `NavigatorDelegate.didFailVisit`
  - External URL routing: non-Season domains open in Safari (`UIApplication.shared.open`)
- `LaunchScreen.storyboard` — Branded splash with "Season" label (#933a35 on #FCF9F7)
- `Info.plist` — Bundle ID `com.season-app.ios`, portrait-only, ATS exceptions
- `PrivacyInfo.xcprivacy` — Privacy manifest (mandatory for App Store)

## Web App Integration

The wrapper loads `https://seasonv2.onrender.com` in a Turbo web view. The web app handles all navigation:

- **Mobile header + burger menu** — visible in native context (May 21 fix)
- **FAB / Quick Actions** — visible in native context (May 21 fix)
- **Calendar icon navigation** — works as normal
- **PWA install/update banners** — hidden in native context
- **External links** — SceneDelegate routes non-Season URLs to Safari

## Auth Flow (Native)

1. User logs in via the web view
2. `SessionsController` returns JSON with `turbo_native_token` when user-agent matches `Turbo Native` / `Season iOS`
3. Token stored in `UserDefaults`, injected as `X-Turbo-Native-Token` header on subsequent requests
4. `TurboNativeDetection` concern validates token on every native request
5. Full auth flow documented in `docs/ios.md`

## Files

| File | Purpose |
|------|---------|
| `project.yml` | XcodeGen config, turbo-ios v8.0.0 via SPM |
| `SeasonApp/AppDelegate.swift` | UIApplicationDelegate entry point |
| `SeasonApp/SceneDelegate.swift` | Turbo Navigator (push/replace nav, error retry, external URL routing) |
| `SeasonApp/Info.plist` | Bundle ID, orientation, ATS exceptions, encryption compliance |
| `SeasonApp/PrivacyInfo.xcprivacy` | Privacy manifest for App Store compliance |
| `SeasonApp/LaunchScreen.storyboard` | Branded splash screen |
| `SeasonApp/Assets.xcassets/AppIcon.appiconset/` | App icon (1024x1024) |

## Completed Features

- **Turbo Native shell** — turbo-ios v8.0.0, Navigator + VisitableViewController + NavigatorDelegate
- **Auth token flow** — X-Turbo-Native-Token header, 30-day expiry, auto-rotation
- **External URL routing** — non-Season domains open in Safari
- **Error handling** — alert with retry on failed visits
- **Push notifications** — Web Push API (webpush gem, PushSubscription model, Stimulus flow)
- **Access code (pin)** — 4-6 digit lock with BCrypt, 5-min auto-lock timer
- **Biometrics (Face ID / Touch ID)** — WebAuthn-based registration + authentication
- **Pull-to-refresh** — Touch-based Stimulus controller with spinner + Turbo.visit refresh
- **Haptic feedback** — `navigator.vibrate()` with multiple intensity patterns
- **PrivacyInfo.xcprivacy** — App Store compliance manifest

## Next Steps

1. **Open Xcode → resolve SPM packages → commit `Package.resolved`**
2. Create Apple Developer account ($99/year)
3. Register app in App Store Connect
4. Archive → Upload → TestFlight
5. Create `path-configuration.json` on Rails side (for Turbo Native route rules — future polish)

---

**Status:** Code-complete. Ready for Apple Developer account setup → TestFlight 📱
