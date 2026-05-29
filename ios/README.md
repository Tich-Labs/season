# Season iOS App

Native iOS wrapper using **Hotwire Native** (`hotwire-native-ios` via SPM).

## Architecture

| File | Purpose |
|------|---------|
| `project.yml` | XcodeGen config — SPM, target iOS 17.2, no auto-generated Info.plist |
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

## Development

**Prerequisites:** Xcode 15.3+ (requires macOS 13+).

```bash
brew install xcodegen
cd ios/SeasonApp
xcodegen generate
open SeasonApp.xcodeproj
```

To test against localhost, build with Debug scheme (uses `http://localhost:3000` base URL).

## Deployment

### Fastlane (recommended)

```bash
cd ios/SeasonApp
fastlane beta
```

### Manual CLI

```bash
cd ios/SeasonApp
xcodegen generate
xcodebuild archive -scheme SeasonApp -archivePath build/SeasonApp.xcarchive -destination generic/platform=iOS
xcodebuild -exportArchive -archivePath build/SeasonApp.xcarchive -exportPath build/ -exportOptionsPlist ExportOptions.plist
xcrun altool --upload-app -f build/SeasonApp.ipa -t ios -u "$APPLE_ID" -p "$APP_SPECIFIC_PASSWORD"
```

## Server Bridge Components

| Component | Server Attribute | Purpose |
|-----------|-----------------|---------|
| `button` | `data-bridge--button` | Native UIBarButtonItem |
| `notification-token` | `data-bridge--notification-token` | Push notification permission + registration |
| `native-auth-token` | `data-bridge--native-auth-token` | Persists auth token in Keychain |

---

**Status:** Hotwire Native with 3-tab bar, push notifications, Keychain auth. CI-ready for TestFlight.
