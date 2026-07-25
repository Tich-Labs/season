# Future Builds

## Android (not yet started)

When Android development begins, replicate the iOS app-resume behavior:

- On app **foreground/resume** (Android `onResume`), explicitly navigate to
  `/calendar` — do not rely on default WebView behavior, which will just
  redisplay whatever screen was last on-screen.
- This applies on top of (not instead of) normal cold-launch session
  handling, which already routes to `/calendar` via `after_sign_in_path`.
- Reference: iOS implementation uses the **Turbo Native / Ruby Native gem**
  (Hotwire's `turbo-ios` equivalent) to hook into
  `sceneDidBecomeActive` / `applicationDidBecomeActive` and force navigation
  back to `/calendar` on resume. Android should mirror this via `onResume`
  in the equivalent Turbo Native Android client.
- Open questions to resolve before implementing:
  - Should this reset apply on every resume, or only after some idle
    threshold (e.g. 5+ min backgrounded)?
  - Should it apply to in-app WebView modals (e.g. Settings) as well as
    full-app backgrounding?
- See also: the `store_location_for` / `user_return_to` mechanism in
  `authentication.rb`, which currently overrides the `/calendar` default
  for post-login redirects from deep links — this same conflict will need
  resolving for Android's resume behavior too.
