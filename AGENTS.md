# AGENTS.md

## Commands

```bash
# Dev server
bin/dev

# Tests (76 passing)
bin/rails test

# Lint
bundle exec rubocop --format simple
bundle exec erb_lint --lint-all --format compact  # NOT erblint

# Pre-commit order: lint -> test -> push
```

## Critical Defaults

- **Database**: PostgreSQL only. No SQLite anywhere. `db/*.sqlite3` are gitignored.
- **Brand primary**: `#933a35` (exact hex from Figma)
- **Field background**: `#EDE1D5` (NOT #F5EDE8)
- **Container**: `max-w-app mx-auto px-4` (430px max-width)
- **Tailwind classes**: Use `text-brand-primary`, NOT `text-[#933a35]`

## Gotchas

- `User#current_phase` returns nil for new users → guard with `|| "Unknown"`
- Use `current_user.onboarding_completed?` not `last_period_start.present?`
- `Admin::FeedbacksController` was deleted → use `Admin::InboxController`
- `config/master.key` is gitignored → get from team password manager
- ERB lint warnings are false positives (parser vs Ruby version)
- `PinProtection` concern auto-locks after 5 min → `skip_before_action :require_pin_unlock` for pin settings
- `PushNotificationService.send_to_user` silently skips users with no subscriptions
- WebAuthn requires HTTPS (localhost exempt); falls back to pin unlock if unavailable
- VAPID keys not in credentials → set `VAPID_PUBLIC_KEY` + `VAPID_PRIVATE_KEY` env vars as fallback

## Asset Rules

- Filenames: lowercase, hyphens only (`season-logo.svg`)
- Use `image_tag`, never `<img src="...">`
- Assets go in `app/assets/images/`

## Error Styling

- Error text: `#933a35`
- Container: `bg-brand-error rounded-xl px-4 py-3`
- Field error: `border border-brand-primary`
- No page redirects → use inline errors with Turbo Stream

## iOS (Turbo Native)

- **Project file**: `ios/SeasonApp/project.yml` — XcodeGen spec
- **Regenerate `.xcodeproj`**: `xcodegen generate` (run from `ios/SeasonApp/`)
- **Base URL**: set `SEASON_BASE_URL` in `Info.plist` (not hardcoded in Swift)
- **Tab model**: `Tabs.swift` (`Tab` struct: title, systemImageName, urlPath)
- **Tab bar controller**: `HotwireTabBarController.swift` — uses `TurboNavigator`
- **Entry point**: `SceneDelegate.swift` — creates `HotwireTabBarController`
- **AppDelegate**: minimal stub — do NOT create `WKWebView` or window there
- **Keychain**: `KeychainHelper.swift` — stores/retrieves native auth token
- **Path rules endpoint**: `GET /configurations/ios_v1.json` (`ConfigurationsController#ios_v1`)
- **SPM**: turbo-ios 1.4.0 from GitHub/hotwired
- **Architecture**: Pure Turbo Native — all views are server-rendered ERB via WKWebView. No SwiftUI views.
- **Auth bridge**: `Session` → WKUserScript extracts `<meta name="native-auth-token">` → Keychain → cookie injected on launch → `TurboNativeDetection` checks header + cookie
- **xcodegen** requires Xcode 15.3+ (macOS 13+)

## Docs
- Figma: `docs/figma_nodes.md`
- Full instructions: `CLAUDE.md`
- iOS integration: `docs/ios.md`
- Progress tracking: `docs/PROGRESS.md`
- Audit system: `docs/AUDIT_SUMMARY.md`, `docs/audit_checklist.md`
- Calendar preferences: `app/helpers/calendar_helper.rb`
- Internal docs: `/docs` (GitHub Pages)