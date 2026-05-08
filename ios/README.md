# Season iOS App (Hotwire Native)

Wrap Season PWA in native iOS shell using Hotwire Native.

## Prerequisites

**Check if Xcode is installed:**
```bash
xcode-select -p
# Returns /Applications/Xcode.app/Contents/Developer if installed
# Returns /Library/Developer/CommandLineTools if NOT installed
```

**Install Xcode (if needed):**
1. Open **Mac App Store** → Search "Xcode" → Install (~12GB)
2. Launch Xcode once → Accept license
3. Run: `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`

**Verify:**
```bash
xcode-select -p
# Should return: /Applications/Xcode.app/Contents/Developer
```

## Setup

1. **Install dependencies:**
   ```bash
   cd ios/SeasonApp
   pod install
   ```

2. **Open in Xcode:**
   ```bash
   open SeasonApp.xcworkspace
   ```

3. **Connect iPhone 13 mini:**
   - Plug in via USB
   - iPhone: Settings → General → About → Trust this Computer
   - Xcode: Window → Devices → Select "TichLabs iPhone 13 mini"

4. **Configure Team (free):**
   - Xcode: Project → Signing & Capabilities
   - Team: Select your Apple ID (free)
   - Bundle ID: `com.season-app.ios`

5. **Run:**
   - Xcode: Select "SeasonApp" scheme
   - Device: "TichLabs iPhone 13 mini"
   - Click **Run (▶️)**

## Configuration

**AppDelegate.swift / SceneDelegate.swift:**
- Points to `https://seasonv2.onrender.com`
- Uses HotwireNavigator for Turbo navigation

## Testing

- App installs directly to your iPhone (no $99 needed)
- Same Rails app, same views, same Hotwire/Turbo
- Native features (push, biometrics) can be added later

## Next Steps

1. Test PWA in native shell
2. Add push notification support
3. Add biometric login (Face ID)
4. Prepare for TestFlight ($99 account)

---

**Status:** Ready for testing 📱

**Files:**
- `ios/SeasonApp/Podfile` — CocoaPods: `pod 'HotwireNative'`
- `ios/SeasonApp/SeasonApp/AppDelegate.swift` — Points to Season
- `ios/SeasonApp/SeasonApp/SceneDelegate.swift` — HotwireNavigator setup
- `ios/SeasonApp/SeasonApp/Info.plist` — Bundle ID: `com.season-app.ios`
