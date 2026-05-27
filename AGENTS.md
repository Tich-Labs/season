# AGENTS.md

## Commands

```bash
# Dev server
bin/dev

# Tests (166 passing)
bin/rails test

# Lint
bundle exec rubocop --format simple
bundle exec erb_lint --lint-all --format compact  # NOT erblint
npx standard app/javascript/controllers/          # JS lint

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
- `omniauth-apple` gem needs `/* global requestAnimationFrame */` in JS controllers using rAF for CI `standard` lint
- Apple OAuth: email only sent on first auth → use UID-first lookup for repeat sign-ins
- Apple OAuth: `omniauth-rails_csrf_protection` v2.0.1 has Rails 8.1 compat issue → patched in `config/initializers/omniauth.rb`
- `calc()` CSS requires spaces around `+` or iOS Safari ignores it: `calc(60px + env(...))` NOT `calc(60px+env(...))`

## Asset Rules

- Filenames: lowercase, hyphens only (`season-logo.svg`)
- **No spaces, no capitals, no umlauts/special chars** — Propshaft fails on production Linux (case-sensitive)
- MacOS `git mv` is case-insensitive → use temp names for case-only renames: `git mv File.png tmp.png && git mv tmp.png file.png`
- Use `image_tag`, never `<img src="...">`
- Assets go in `app/assets/images/`

## Error Styling

- Error text: `#933a35`
- Container: `bg-brand-error rounded-xl px-4 py-3`
- Field error: `border border-brand-primary`
- No page redirects → use inline errors with Turbo Stream

## Icon Selection Pattern (standard for all icon grids)

When building tappable icon-selectors (moods, cravings, etc.), follow this pattern consistently:

**Visual state** — use inline opacity + grayscale, NOT background color changes:
- **Selected**: `opacity: 1; transform: scale(1.08);` (full color, slight pop)
- **Unselected**: `opacity: 0.35; transform: scale(1); filter: grayscale(0.6);` (faded, desaturated)

**Server-render initial state** via inline styles:
```erb
<% sel = list.include?('item-key') %>
<button data-action="click->symptom#toggleMethod" data-item-key="item-key"
        style="opacity:<%= sel ? 1 : 0.35 %>;transform:scale(<%= sel ? 1.08 : 1 %>);filter:<%= sel ? '' : 'grayscale(0.6)' %>;">
  <div class="w-14 h-14 flex items-center justify-center">
    <%= image_tag "path/to/icon.svg", alt: "Label" %>
  </div>
</button>
```

**JS toggles** via direct style manipulation (match `#applyMoodVisuals` / `#applyCravingVisuals`):
```js
#applyVisuals () {
  this.element.querySelectorAll('[data-item-key]').forEach(btn => {
    const selected = this.#activeItems.includes(btn.dataset.itemKey)
    btn.style.opacity = selected ? '1' : '0.35'
    btn.style.transform = selected ? 'scale(1.08)' : 'scale(1)'
    btn.style.filter = selected ? '' : 'grayscale(0.6)'
    btn.setAttribute('aria-pressed', selected.toString())
  })
}
```

**Do NOT** use background-color circles, border highlights, or CSS class toggling for selected state. The opacity/grayscale pattern keeps the native icon colors and works uniformly on any background.

## Scroll Pickers (vertical + horizontal)

Two picker patterns exist for numeric input. Prefer the **vertical** one for mobile.

### Vertical Picker (`vertical_picker_controller.js`)
Used for Sleep (1–12h), Temperature (35.0–42.0°C), Weight (30.0–200.0 kg).

- Controller: `data-controller="vertical-picker"`
- Values: `min`, `max`, `step`, `value`, `unit`, `field`
- Target: `display` (text element), `track` (scroll container)
- Event: `vertical-picker:change` → `symptom#saveFromPicker`
- CSS: `.vp-track`, `.vp-item`, `.vp-bg` (center highlight bar), `.vp-display`

### Horizontal Picker (`scroll_picker_controller.js`)
Legacy — used nowhere currently, kept for reference.

## Date Picker Drum (`date_picker_controller.js`)

Expandable pill used on Symptoms and Superpowers pages.

- **Collapsed**: 155×31px pill (`border-radius: 133px`), `#EDE1D5` bg
- **Expanded**: 155×215px card (`border-radius: 25px`), scrollable date list
- Targets: `drum` (container), `content` (expanded panel)
- Transition: `transition-all duration-300` on height + border-radius
- Uses `/* global requestAnimationFrame */` for standard JS lint

## Pre-Submit Review Modal

On Symptoms page, Submit button opens a review modal (`submit_modal_controller.js`) summarizing:
- Mood count + names
- Physical symptoms with levels (e.g., "Headaches → Medium")
- Mental symptoms with levels
- Other counts (Bleeding, Intercourse, Cravings, Sleep, Temp, Weight)
- "Submit tracking" → navigates to `/tracking`
- "Go back to change" → closes modal

## Pages Summary

| Page | Status | Key Features |
|---|---|---|
| Welcome | ✅ | Social login, sign-up |
| Sign In / Sign Up | ✅ | Google, Facebook, Apple OAuth |
| Self Analysis (`/tracking`) | ✅ | Avatar, phase, cycle strip, daily analysis card, nav cards |
| My Symptoms (`/symptoms`) | ✅ | Date drum, mood icons, physical/mental sliders, bleeding drops, intercourse grid, cravings grid, discharge grid, sleep/temp/weight vertical pickers, notes, submit → review modal |
| Superpowers (`/superpowers`) | ✅ | Date drum, phase label, 20 sliders (low/med/high), submit |
| Track Period (`/tracking/period`) | ✅ | Greeting, month nav, period bar, horizontal calendar, submit |
| Calendar | ✅ | Cycle day grid |
| PWA | ✅ | manifest.json, service-worker.js |
| iOS Turbo Native | ✅ | Hotwire Native integration |

## iOS (Turbo Native)

- **Project file**: `ios/SeasonApp/project.yml` — XcodeGen spec
- **Regenerate `.xcodeproj`**: `xcodegen generate` (run from `ios/SeasonApp/`)
- **Base URL**: hardcoded in `Tabs.swift:4` (not Info.plist)
- **SPM**: `https://github.com/hotwired/hotwire-native-ios` (HotwireNative package, >= 1.0.0)
- **AppDelegate**: loads `path-configuration.json` + remote `/configurations/ios_v1.json` via `Hotwire.loadPathConfiguration(from:)`
- **SceneDelegate**: creates `Navigator` with `startLocation: baseURL`, calls `navigator.start()`, sets `window?.rootViewController = navigator.rootViewController`
- **CRITICAL**: `navigator.start()` MUST be called — without it, the Navigator never creates its WebView or begins the visit lifecycle
- **Tab bar**: `HotwireTabBarController` (from HotwireNative library) loaded via `switchToTabs()` when user reaches authenticated paths
- **Path rules endpoint**: `GET /configurations/ios_v1.json` (`ConfigurationsController#ios_v1`)
- **Bundled path config**: `ios/SeasonApp/SeasonApp/path-configuration.json`
- **Architecture**: Pure Hotwire Native — all views are server-rendered ERB. Navigator manages its own WebView internally. No direct WKWebView creation.
- **No KeychainHelper / WKUserScript auth bridge** — not yet implemented
- **xcodegen** requires Xcode 15.3+ (macOS 13+)

## Docs
- Figma: `docs/figma_nodes.md`
- Full instructions: `CLAUDE.md`
- iOS integration: `docs/ios.md`
- Progress tracking: `docs/PROGRESS.md`
- Audit system: `docs/AUDIT_SUMMARY.md`, `docs/audit_checklist.md`
- Calendar preferences: `app/helpers/calendar_helper.rb`
- Internal docs: `/docs` (GitHub Pages)