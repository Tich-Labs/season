# Season iOS App

Native iOS wrapper using **Hotwire Native** (`hotwire-native-ios` via SPM).

## Architecture

| File | Purpose |
|------|---------|
| `project.yml` | XcodeGen config — SPM, target iOS 16.0, no auto-generated Info.plist |
| `SeasonApp/AppDelegate.swift` | Minimal UIApplicationDelegate |
| `SeasonApp/SceneDelegate.swift` | `HotwireTabBarController` + `NavigatorDelegate` |
| `SeasonApp/Tabs.swift` | Calendar / Tracking / Settings tab definitions |
| `SeasonApp/Info.plist` | Bundle ID, scene manifest, ATS, encryption |
| `SeasonApp/PrivacyInfo.xcprivacy` | App Store compliance |
| `SeasonApp/LaunchScreen.storyboard` | Branded splash |
| `SeasonApp/Assets.xcassets/AppIcon.appiconset/` | All icon sizes |
| `ExportOptions.plist` | App Store signing config |

## Web App Integration

- **Native tab bar** replaces web burger menu + FAB (hidden in native)
- **Path config** at `/configurations/ios_v1.json` — Settings/Account open as modals
- **Auth** via `X-Turbo-Native-Token` header → `TurboNativeDetection` concern
- **External URLs** routed to system browser by Hotwire Native SDK

## Development

**⚠️ macOS 12 users:** Hotwire Native requires Swift 5.9+ (Xcode 15+). Build via CI (`macos-latest` runner). Local testing: use plain WKWebView on Xcode 14.2.

## Setup

```bash
brew install xcodegen   # macOS 13+ only
cd ios/SeasonApp
xcodegen generate
open SeasonApp.xcodeproj
```

## CI

GitHub Actions cloud Mac (Xcode 16): xcodegen → SPM resolve → archive → manual codesign → zip IPA → altool upload.

**9 GitHub secrets required** — see `docs/STORE-DEPLOYMENT.md` for the full setup guide.

---

**Status:** Hotwire Native with 3-tab bar. Ready for CI signing → TestFlight.
