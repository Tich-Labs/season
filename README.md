# Season

Women's health tracking app — Rails 8 + Hotwire + Hotwire Native (iOS and Android).

**Live**: [seasonv2.onrender.com](https://seasonv2.onrender.com)

## Stack

- **Backend**: Ruby 3.4, Rails 8, PostgreSQL
- **Frontend**: Tailwind CSS, Stimulus, Turbo
- **Mobile**: Hotwire Native iOS + Android
- **Hosting**: Render
- **Queue**: SolidQueue (in-process with Puma)

## Setup

```bash
bin/setup
bin/dev
```

Requires Ruby 3.4+, PostgreSQL, and the master key (`config/master.key`).

## Branching Workflow

| Branch | Purpose |
|--------|---------|
| `main` | Production; beta hotfixes have been pushed here directly |
| `dev` | Development branch for integrated feature work |

Preferred contribution flow:

```bash
git checkout dev
git checkout -b feature/your-feature
# ... make changes ...
git push -u origin feature/your-feature
# Open a PR from feature/your-feature → dev
# Then open a PR from dev → main
```

## Commands

```bash
bin/dev                                      # Start dev server
bin/rails test                               # Run full test suite
bundle exec rubocop --format simple           # Ruby lint
bundle exec erb_lint --lint-all --format compact  # ERB lint
npx standard app/javascript/controllers/     # JS lint
```

Run all checks before pushing. The pre-push hook currently runs Ruby lint.

## Native apps

Both apps are Hotwire Native wrappers around `https://seasonv2.onrender.com`. Server-rendered Rails views are displayed inside native navigation stacks.

### Password reset deep links

Rails serves the association files used by iOS Universal Links and Android App Links:

- `/.well-known/apple-app-site-association`
- `/.well-known/assetlinks.json`

iOS declares `applinks:seasonv2.onrender.com`; Android declares a verified `VIEW` intent filter for `seasonv2.onrender.com` password reset paths. Password reset URLs open the native app when installed and fall back to the web app otherwise.

These endpoints must be deployed before rebuilding the native apps with the updated entitlements/intent filters.

### Android local testing

Point the Android wrapper at any base URL at build time:

```bash
bin/dev
cd android
./gradlew :app:installDebug -PwebBaseUrl=http://10.0.2.2:3000
```

- Emulator: use `10.0.2.2` for the Mac localhost.
- Physical device: use the Mac LAN IP, for example `http://192.168.1.42:3000`.
- Public tunnel: pass `-PwebBaseUrl=https://...`.

### Android release build

Release AABs use Play package `com.onrender.seasonv2.rubynative`. Create a gitignored `android/keystore.properties` with upload-key credentials, then:

```bash
cd android
./gradlew :app:bundleRelease -PciVersionCode=102 -PciVersionName=1.0.102
jarsigner -verify app/build/outputs/bundle/release/app-release.aab
```

The signed AAB is written to `android/app/build/outputs/bundle/release/app-release.aab`. GitHub Actions validates signing/Play secrets before uploading to the configured track.

## Google Calendar

Production always uses:

```text
https://seasonv2.onrender.com/settings/google_calendar_callback
```

For local OAuth testing, set this in gitignored `.env`:

```text
GOOGLE_CALENDAR_REDIRECT_URI=http://127.0.0.1:3000/settings/google_calendar_callback
```

The same Google OAuth client must include both the production and local callback URLs in **Authorized redirect URIs**. Restart `bin/dev` after changing `.env`.

## Docs

- `AGENTS.md` — critical defaults, gotchas, iOS best practices
- `docs/` — Figma notes, iOS integration, and audit notes
- `ios/SeasonApp/` — Xcode project for the iOS Hotwire Native app
- `android/` — Gradle project for the Android Hotwire Native app
