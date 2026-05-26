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

## Setup

```bash
brew install xcodegen
cd ios/SeasonApp
xcodegen generate
open SeasonApp.xcodeproj
```

## CI

GitHub Actions: `xcodegen generate` → SPM resolve → archive → sign → upload to TestFlight.
See `.github/workflows/ios.yml` and `docs/STORE-DEPLOYMENT.md`.

---

**Status:** Hotwire Native with 3-tab bar. Ready for CI signing → TestFlight.
