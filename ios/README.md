# Season iOS App

Native iOS wrapper using **Hotwire Native** (`hotwire-native-ios` via SPM).

## Architecture

| File | Purpose |
|------|---------|
| `SeasonApp.xcodeproj` | Xcode project — uses `PBXFileSystemSynchronizedRootGroup` (Xcode 16+ auto-syncs source files) |
| `SeasonApp/AppDelegate.swift` | Path config loading, bridge component registration, push notification callbacks |
| `SeasonApp/SceneDelegate.swift` | `HotwireTabBarController` as root VC, notification router, `NavigatorDelegate` |
| `SeasonApp/Tabs.swift` | Calendar / Tracking / Settings tab definitions (tabs from launch) |
| `SeasonApp/Components/` | Bridge components: ButtonComponent, NotificationTokenComponent, NativeAuthTokenComponent |
| `SeasonApp/Models/` | NotificationRouter, NotificationToken, KeychainHelper |
| `SeasonApp/ViewModels/` | NotificationTokenViewModel |
| `SeasonApp/SeasonApp.entitlements` | Push notification capability (aps-environment) |
| `SeasonApp/Info.plist` | Bundle ID, scene manifest, ATS, push background mode |
| `SeasonApp/PrivacyInfo.xcprivacy` | App Store compliance |
| `SeasonApp/LaunchScreen.storyboard` | Branded splash |
| `SeasonApp/Assets.xcassets/AppIcon.appiconset/` | All icon sizes |
| `ExportOptions.plist` | App Store Connect signing config |
| `Fastlane/Fastfile` | Build + TestFlight upload lane |

## Key Design Decisions

- **`HotwireTabBarController` from launch** — no pre-auth navigator or `switchToTabs()`. All 3 tabs (Calendar, Tracking, Settings) are available immediately. Unauthenticated users see login within the tabs.
- **Auth via cookies + Keychain** — session cookie handles WKWebView auth automatically. Token bridge (`NativeAuthTokenComponent`) stores `native_auth_token` in Keychain for cold-restart persistence.
- **Push notifications** — `NotificationTokenComponent` bridge requests permission on the page it appears. `NotificationRouter` handles notification taps and routes to the correct screen.
- **Path config from server only** — rules served at `/configurations/ios_v1.json`. Settings/Account open as modals.
- **No XcodeGen** — `.xcodeproj` is committed directly (macOS 12 host cannot compile XcodeGen). Project uses Xcode 16+'s `PBXFileSystemSynchronizedRootGroup` which auto-discovers files — adding new Swift files just requires placing them in the `SeasonApp/` directory and re-running SPM resolution.

## Development

**Prerequisites:** Xcode 15.3+ on a macOS 13+ machine.

```bash
open SeasonApp.xcodeproj
# Wait for SPM to resolve HotwireNative dependency
# Build and run from Xcode
```

To test against localhost, build Debug scheme (uses `http://localhost:3000` base URL).
Release builds use `https://seasonv2.onrender.com`.

## Deployment

### Fastlane (recommended, runs on CI)

```bash
cd ios/SeasonApp
fastlane beta
```

### Manual CLI

```bash
cd ios/SeasonApp
xcodebuild archive -scheme SeasonApp -archivePath build/SeasonApp.xcarchive -destination generic/platform=iOS
xcodebuild -exportArchive -archivePath build/SeasonApp.xcarchive -exportPath build/ -exportOptionsPlist ExportOptions.plist
xcrun altool --upload-app -f build/SeasonApp.ipa -t ios -u "$APPLE_ID" -p "$APP_SPECIFIC_PASSWORD"
```

Before TestFlight, change `aps-environment` in `SeasonApp.entitlements` from `development` to `production`.

## Server Bridge Components

| Component | Server Attribute | Purpose |
|-----------|-----------------|---------|
| `button` | `data-bridge--button` | Native UIBarButtonItem |
| `notification-token` | `data-bridge--notification-token` | Push notification permission + registration |
| `native-auth-token` | `data-bridge--native-auth-token` | Persists auth token in Keychain |

---

**Status:** Hotwire Native with 3-tab bar, push notifications, Keychain auth. CI-ready for TestFlight.
