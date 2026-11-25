# Beta Changelog — Oct 7 Beta Period

Scope: beta-facing changes from `2026-10-07` through the current working tree. There are no commits dated `2026-10-07`.

This is the running record for the Oct 7 beta. Add a dated entry here for every beta-facing change, fix, deployment change, or QA status change.

## Status summary

- Web production host: `seasonv2.onrender.com`.
- iOS: Hotwire Native is the only native stack. TestFlight build succeeded; iOS CI publishes a signed IPA artifact for manual Transporter upload.
- Android: historical Play upload was manual/local. GitHub Android CI is scaffolded but still needs `ANDROID_KEY_ALIAS`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, and `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`. Correct package ID is `com.onrender.seasonv2.rubynative` (confirmed in Google Play).
- Legacy Ruby Native integration has been removed.
- Security audit: Brakeman clean, bundler-audit clean after `rack-protection` `4.2.2`, importmap clean, npm audit clean. Manual P1/P2/P3 findings remain tracked separately.
- Trello fixing list: safe-area, menu, and top-bar issues are fixed.
- Trello testing list: streak counter, Google Calendar 500/OAuth config, and translations are fixed. “Track your day” is regression-only.
- Not done: Apple calendar sync. Copper IUD has a copy-only commit but is still not marked done in Trello.

## 2026-10-08

- `8ce78cb` — iOS beta confirmation now shows the public TestFlight link with simpler “Open in TestFlight” wording.

## 2026-10-11

- `0a8b212` — Android beta invitations prefer the Google Play Developer API and fall back to emailed self-serve invites when the API is unavailable.
- `4f0eb0d` — Large English-to-German localization pass across app screens, JS labels, pickers, and tester tour assets. Removed the redundant launch splash and old launch waitlist.

## 2026-10-12

- `321f7c8` — Localized forecast content, support modal, settings titles, and German tester-tour screenshots.
- `0cb15e7` — Streak forgiveness: one missed non-rest day per week and missed period “rest days” no longer reset progress. Quick tracking actions count as tracking wins.
- `c8d0870` — Localized page titles and information pages in English and German.

## 2026-10-13

- `4190c07` — Added client-side translations for Stimulus controllers and localized remaining screens, modals, date pickers, and account-deletion mailer copy.
- `dee4dd3` — Fixed Google Calendar connect 500: rejected/expired token exchanges now redirect back with a failure alert and log the real reason.
- `bf54cbc` — Fixed client-side i18n nesting so JS strings render translated text instead of raw keys such as `js.reminder_minutes`.
- `6889d17` — Locale-only copy change from generic “IUD” to “Copper IUD” / “Kupferspirale”. QA caveat: Trello still marks Copper IUD as not done.
- `f370697` — Fixed native-app detection so the Hotwire Native iOS app gets native-only layout behavior, safe-area handling, and PWA banner gating.

## 2026-11-01

- `e677a1b` — Continued localization across app copy and mailers; added “Track my day” inside the Forecast tab for today/past dates. QA scope: regression-only.
- `cf702a1` — Commented out unused birth-control locale keys for the unmerged schedule feature while preserving English/German parity.
- `5cf553a` — Morning, period, and birth-control reminders are greyed out with “Coming soon” pills; sub-pages remain reachable by URL.
- `59c6002` — “My Subscriptions” and “Notifications & Reminders” are greyed out / marked “Coming soon” in settings.
- `068194a` — Added calendar event source tracking (`season`/`google`), minimized imported Google event fields, and added Google token encryption/revocation work.
- `ac74b04` — Added calendar sync levels and gated Google pushes by sync level; disconnect removes Season-created Google copies.
- `6f75839` — Removed Active Record encryption on Google tokens until encryption keys are configured in production.
- `dfcd9d9` — Synced `db/schema.rb` with calendar source and sync-level columns.
- `9a68025` — Simplified the calendar source migration to rely on the column default.
- `a343d22` — Android Hotwire shell fixes: registered the web fragment, hid the native toolbar, added status-bar padding, and disabled the native bottom tab bar.

## 2026-11-02

- `518d30b` — Stopped tracking internal docs not linked from admin or loaded by the app; files remain on disk and older copies remain in git history.

## 2026-11-21

- `58970a5` — Broad beta feedback pass:
  - Fixed safe-area, menu, and top-bar issues from Trello.
  - Fixed menu FAB overlay behavior using a shared `[data-calendar-fab]` selector.
  - Streak backfills now recompute from real tracking dates via `Streaks::RecomputeService`.
  - Google Calendar OAuth uses the v2 endpoint, validates required credentials, supports a fixed redirect URI, and configures OmniAuth allowed hosts.
  - Expanded localization for legal terms, PWA/offline text, avatar preset names, push notifications, birth-control reminder copy, discharge guidance, calendar fallbacks, and phase/season labels.
  - Localized reminder and weekly feedback push notifications with recipient/user locale.
- `9174016` — Bumped Ruby to `3.4.13` and updated Render config for CI runner compatibility.
- `499e53e` — Fixed an environment-dependent settings test and updated Brakeman.

## 2026-11-22

- `89d2495` — Tracked the Gradle wrapper so Android CI can build reproducibly.
- `71e3f02` — Suppressed R8 missing-annotation-class warnings.
- `288fc1c` — Android CI validates required signing/Play secrets before building.
- `025d35f` — Corrected Android package/application ID to `com.seasonapp.android`.

## 2026-11-24

- `0090a56` — Removed legacy Ruby Native integration; Hotwire Native is now the single native stack. Replaced Ruby Native layout/JS/CSS hooks with native-app safe-area hooks.
- `1f14cef` — Bundler-audit fix: bumped `rack-protection` to `4.2.2` and pruned orphaned QR dependencies left by Ruby Native removal.
- `b4b1182` — iOS CI publishes a signed IPA artifact for manual Transporter upload and raises build numbers to avoid duplicate TestFlight builds.

## 2026-11-25

- Restored Play package `com.onrender.seasonv2.rubynative` in Gradle, Android CI fallback, App Links, tests, README, and deployment docs after a conflicting change to `com.seasonapp.android`.
- Android local release signing works from gitignored `android/keystore.properties` or `ANDROID_KEY_*` env vars; unsigned AABs remain the CI/r0adkll path.
- iOS CI now uses the `xcode-27` runner and fails fast unless the iOS 27 SDK is present; IPA is still downloaded and uploaded via Transporter.

## Current working tree — not committed yet

### Google Calendar import fixes

- Connecting Google Calendar now imports events immediately instead of only storing OAuth tokens.
- Added `GoogleCalendarImportService` so connect and “Sync now” use the same import path.
- Duplicate Google event IDs are scoped per user, so one user's event no longer blocks another user's import.
- Production Google Calendar OAuth now always uses `https://seasonv2.onrender.com/settings/google_calendar_callback`, preventing stale localhost/proxy hosts from causing `redirect_uri_mismatch`.
- Local development uses `http://127.0.0.1:3000/settings/google_calendar_callback` from gitignored `.env`; Google Cloud must register that URI for local testing.

### Calendar sync direction work in progress

- Connect-time sync-direction choice (`one_way` / `two_way`) is being added under Settings → Calendar.
- Persists direction changes, imports Google events in one-way mode, and backfills existing Season events when switching to two-way.
- Clears stale Google credentials on authorization failure.
- Apple calendar sync is not done.

### Password reset deep-link UX

- Best UX agreed: reset email opens a verified web link; on installed native apps it should open Season via Universal Links / App Links, show the reset page in the native stack, and return the user to the app after success.
- Rails now serves:
  - `/.well-known/apple-app-site-association`
  - `/.well-known/assetlinks.json`
- iOS now declares `applinks:seasonv2.onrender.com` and routes eligible `NSUserActivity` web URLs through the Hotwire Native navigator.
- Android now declares a verified `VIEW` intent filter for `seasonv2.onrender.com` password reset paths and routes incoming App Link intents through the Hotwire Native navigator.
- Native path configuration now treats `/users/password/*` and `/password/*` as `presentation: replace`, so an expired/reset token screen is not left stacked in the navigation history.

### Android signing/deployment in progress

- Local release signing support via gitignored `android/keystore.properties` or `ANDROID_KEY_*` environment variables.
- Gitignore now ignores keystore/signing artifacts.
- Package ID in Gradle, CI fallback, App Links controller, and docs reconciled to `com.onrender.seasonv2.rubynative` (the app in Play Console).
- Remaining GitHub secrets must be added before Android CI can upload to Play.

### Miscellaneous working-tree changes

- Added a 44×44 minimum touch target for `.toggle-btn` and rebuilt Tailwind.
- Added `ios_native?` detection to distinguish iOS EventKit-capable clients from Android/web CalDAV fallback.
- `Season.code-workspace` is an untracked IDE workspace file, not an app change.

## Operational notes

- Calendar OAuth local testing:
  - Restart `bin/dev` after changing `.env`.
  - Add `http://127.0.0.1:3000/settings/google_calendar_callback` and `http://localhost:3000/settings/google_calendar_callback` to the same Google OAuth client in Google Cloud.
  - Keep `https://seasonv2.onrender.com/settings/google_calendar_callback` registered for production.
- Password reset deep links require deployment of the Rails well-known endpoints plus a native build with the new iOS entitlement / Android intent filter.
- Android App Links fingerprint is derived from the committed upload certificate; if the upload key is ever replaced, update `ANDROID_APP_LINKS_SHA256`.
