# Season iOS App

Wrap Season PWA in a native iOS shell using plain WKWebView. Zero external dependencies.

## Prerequisites

```bash
# Check if Xcode is installed
xcode-select -p
# Should return: /Applications/Xcode.app/Contents/Developer

# Install XcodeGen (macOS 13+)
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

2. **Configure Team:**
   - Xcode: Project → Signing & Capabilities
   - Team: Select your Apple ID
   - Bundle ID: `com.season-app.ios`

3. **Run:**
   - Select "SeasonApp" scheme → iPhone / Simulator
   - Click **Run (▶️)**

## Architecture

**Zero dependencies** — plain WKWebView with WKNavigationDelegate.

| File | Purpose |
|------|---------|
| `project.yml` | XcodeGen config — generates the `.xcodeproj` |
| `SeasonApp/AppDelegate.swift` | UIApplicationDelegate entry point |
| `SeasonApp/SceneDelegate.swift` | WKWebView + ViewController + WKNavigationDelegate |
| `SeasonApp/Info.plist` | Bundle ID, orientation, ATS exceptions, scene manifest, encryption |
| `SeasonApp/PrivacyInfo.xcprivacy` | App Store compliance manifest |
| `SeasonApp/LaunchScreen.storyboard` | Branded splash screen |
| `SeasonApp/Assets.xcassets/AppIcon.appiconset/` | All icon sizes |
| `ExportOptions.plist` | App Store export signing config |

## Web App Integration

The wrapper loads `https://seasonv2.onrender.com` in a WKWebView. The web app handles all navigation:

- **Mobile header + burger menu** — visible in native context
- **FAB / Quick Actions** — visible in native context
- **PWA install/update banners** — hidden in native context
- **External URLs** — WKNavigationDelegate routes to Safari

## Auth Flow (Native)

1. User logs in via the web view
2. `SessionsController` returns JSON with `turbo_native_token` when user-agent matches `Season iOS`
3. Token stored, injected as `X-Turbo-Native-Token` header on subsequent requests
4. `TurboNativeDetection` concern validates token on every native request

## Completed Features

- **WKWebView wrapper** — plain WKWebView, zero dependencies, 2 Swift files
- **External URL routing** — OAuth, privacy, terms open in Safari
- **Auth token flow** — X-Turbo-Native-Token header
- **PrivacyInfo.xcprivacy** — App Store compliance
- **All icon sizes** — asset catalog with full set
- **Push notifications** — Web Push API
- **Pin lock screen** — BCrypt, 5-min auto-lock
- **Biometrics** — WebAuthn (Face ID / Touch ID)
- **CI workflow** — GitHub Actions cloud Mac builds, signs, uploads

## CI Setup (see `docs/STORE-DEPLOYMENT.md`)

Requires GitHub secrets:
- `DEVELOPMENT_TEAM` — `CH4G9T6ZHP`
- `APPLE_ID` + `APP_SPECIFIC_PASSWORD`
- `APPSTORE_KEY_ID` + `APPSTORE_ISSUER_ID` + `APPSTORE_KEY_BASE64` (App Store Connect API Key)

Then: GitHub → Actions → iOS Build → Run workflow.

---

**Status:** Code-complete. CI + App Store Connect API key setup before TestFlight.
