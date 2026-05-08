# Season iOS App (Hotwire Native)

Wrap Season PWA in native iOS shell using Hotwire Native.

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
   - Xcode → Window → Devices → Select your iPhone
   - Trust computer on iPhone

4. **Run:**
   - Xcode → Select "SeasonApp" scheme
   - Device: "TichLabs iPhone 13 mini"
   - Click Run (▶️)

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
