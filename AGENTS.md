# AGENTS.md

## Commands

```bash
# Dev server
bin/dev

# Tests (166 passing, 0 failures)
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
- Layout bottom padding: `<main>` in `application.html.erb` reserves 8rem ONLY when the shared "+" quick-actions FAB renders (pages that set `hide_quick_actions`). Pages with a bottom FAB own their own clearance inside their wrapper: center-FAB pages use `pb-28` (112px ≥ FAB top at 106px), `/calendar` uses `pb-32` (its "+" sits at 3rem). Do NOT add blanket `<main>` bottom padding — it shows as a band of `#FAF7F4` dead space below white content.
- New `pb-*` utilities added to views need `bin/rails tailwindcss:build` (JIT only emits classes found in source at build time); commit the rebuilt `app/assets/builds/tailwind.css`.
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
- Apple OAuth + Google OAuth on iOS: session cookie is frequently not sent with `button_to` form POSTs (Safari ITP / WKWebView behavior). The CSRF monkey-patch in `config/initializers/omniauth.rb` handles BOTH exceptions AND false returns from `valid_authenticity_token?` to prevent silent OAuth redirect blocking.
- OAuth buttons use `button_to` with `data: { turbo: false }` — equivalent to `form_with local: true`. Do NOT change to Turbo-based submission.
- `calc()` CSS requires spaces around `+` or iOS Safari ignores it: `calc(60px + env(...))` NOT `calc(60px+env(...))`
- `font-['Montserrat']` Tailwind arbitrary values break ERB compiler when combined with inline `<%= %>` in same element → use `font-sans` instead (maps to Montserrat in Tailwind config)
- Signup and login forms MUST use `local: true` on `form_with` — Turbo's Fetch-based submission conflicts with iOS Safari's cookie/CSRF handling
- Seed data is automated via `render-build.sh` (`rails db:seed` after `db:prepare`) — uses `find_or_create_by!` so safe to re-run
- Onboarding step 10 (period date): submit buttons MUST be inside their respective `<form>` elements. iOS Safari/WKWebView blocks `form.submit()` when called from a button outside the form. Use `<button type="submit">` inside the form, never `onclick="document.getElementById('...').submit()"`.
- Weekly feedback modals: three separate modals exist — `_feedback_modal.html.erb` (general feedback), `_support_modal.html.erb` (support + bug), `_weekly_feedback_modal.html.erb` (8-week survey). Each has its own Stimulus controller and event name. Render all three in every authenticated layout.
- `open_feedback_controller.js` uses dual approach for iOS reliability: **direct `container.style.display = 'flex'`** as primary mechanism, plus `CustomEvent` dispatch for the modal controller to set up type-specific UI (headings/placeholders). Do NOT rely on events alone — iOS WKWebView can lose event listeners across Turbo Native modal boundaries.
- Feedback/support modals MUST also be rendered **inline in the pages that trigger them** (`settings/edit.html.erb`, `tracking/index.html.erb`) as a safeguard. iOS Turbo Native opens Settings as a separate WebView modal — if the modal partial is only in the layout, the button's event may not reach it.
- Logout MUST use `button_to ... method: :delete` NOT `link_to data: { turbo_method: :delete }`. The `data-turbo-method` approach requires Turbo's JS handler; if it fails on iOS, the link 404s. `button_to` generates a proper HTML form that works without JS.

## iOS UX Best Practices

- **Touch targets**: Minimum 44×44px (Apple HIG). Use `p-2` not `p-1` on buttons with small SVGs
- **Input font-size**: Minimum 16px to prevent iOS Safari zoom. Never use `text-sm` (14px) on `<input>`, `<textarea>`, `<select>`
- **Tap delay**: `touch-action: manipulation` set globally in `application.tailwind.css`
- **Tap highlight**: `-webkit-tap-highlight-color: transparent` set globally
- **Text selection**: `user-select: none` on buttons, summaries, `[data-action]` elements
- **Slider thumbs**: Use `radial-gradient(circle at center, COLOR 10px, transparent 10px)` on a 44×44px thumb to increase hit area while keeping visible dot at 20px
- **`min-h-screen` → `min-h-dvh`**: Always pair with `min-h-screen` as fallback for older iOS

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
| Self Analysis (`/tracking`) | ✅ | Avatar, phase, cycle strip, daily analysis card, nav cards, weekly feedback nudge banner |
| My Symptoms (`/symptoms`) | ✅ | Date drum, mood icons, physical/mental sliders, bleeding drops, intercourse grid, cravings grid, discharge grid, sleep/temp/weight vertical pickers, notes, submit → review modal |
| Superpowers (`/superpowers`) | ✅ | Date drum, phase label, 20 sliders (low/med/high), submit |
| Track Period (`/tracking/period`) | ✅ | Greeting, month nav, period bar, horizontal calendar, submit |
| Forecast (`/forecast`) | ✅ | 2-tab view (appointments + forecast cards), phase-colored, modal detail, cycle-day content from seed data |
| Calendar | ✅ | Cycle day grid |
| PWA | ✅ | manifest.json, service-worker.js |
| iOS Turbo Native | ✅ | Hotwire Native integration |

## Weekly Feedback System (8-week survey)

- **Admin CMS**: `/admin/weekly_feedback_questions` — create/edit/delete questions per week (1-8)
  - 3 question types: `multiple_choice` (3-5 options), `yes_no_with_input` (Yes/No + Why text), `text_only`
  - Reorder within a week via `position`, active/inactive toggle
- **Admin Responses**: `/admin/weekly_feedback_responses` — table view + CSV export
- **User Modal**: `_weekly_feedback_modal.html.erb` with `weekly_feedback_modal_controller.js`
  - Fetches current week's questions via `GET /weekly_feedback`
  - Submits answers via `POST /weekly_feedback/submit`
  - Renders dynamic UI per question type (tap buttons, yes/no toggle, textarea)
- **Week Calculation**: `User#current_feedback_week` — `((Time.now - created_at) / 7.days).ceil.clamp(1, 8)`
- **Nudge System**:
  - In-app banner on tracking page (green bar with week label)
  - Push notification job (`SendWeeklyFeedbackNudgesJob`) — daily at 10am
  - Controller: `weekly_feedback_nudge_controller.js`
- **Forwarding**: Each response fires `WeeklyFeedbackMailer#summary` → Trello email

## iOS (Hotwire Native)

- **Project file**: `ios/SeasonApp/SeasonApp.xcodeproj` is committed directly — there is NO XcodeGen spec in the repo
- **Regenerate `.xcodeproj`** if corrupted: run `python3 gen.py` from `ios/SeasonApp/` (generates fresh UUIDs)
- **Base URL**: hardcoded in `Tabs.swift:4` (not Info.plist)
- **SPM**: `https://github.com/hotwired/hotwire-native-ios` (HotwireNative package, >= 1.0.0)
- **AppDelegate**: loads `path-configuration.json` + remote `/configurations/ios_v1.json` via `Hotwire.loadPathConfiguration(from:)`
- **SceneDelegate**: creates `Navigator` with `startLocation: baseURL`, calls `navigator.start()`, sets `window?.rootViewController = navigator.rootViewController`
- **CRITICAL**: `navigator.start()` MUST be called — without it, the Navigator never creates its WebView or begins the visit lifecycle
- **Path rules endpoint**: `GET /configurations/ios_v1.json` (`ConfigurationsController#ios_v1`, `config/routes.rb:276`)
- **Bundled path config**: `ios/SeasonApp/SeasonApp/path-configuration.json`
- **Architecture**: Pure Hotwire Native — all views are server-rendered ERB. `Navigator` manages its own WebView internally. No direct WKWebView creation.
- **PBXFileSystemSynchronizedRootGroup** — Xcode 16+ auto-discovers source files in the `SeasonApp/` directory
- **Source files** (8 total, all under `ios/SeasonApp/SeasonApp/`): `AppDelegate`, `SceneDelegate`, `Tabs`, `ButtonComponent`, `NotificationTokenComponent`, `NotificationToken`, `NotificationRouter`, `NotificationTokenViewModel`
- **Push notifications**: `NotificationTokenComponent` → `NotificationRouter` → `NotificationTokenViewModel`
- **No KeychainHelper / WKUserScript auth bridge** — not implemented. There is no `NativeAuthTokenComponent.swift` and no `KeychainHelper.swift`; native auth currently rides on the Rails session cookie.

### Rails-side native layer (`ruby_native` gem)

The Rails side is **not** Hotwire Native — it uses the `ruby_native` gem (`~> 0.10.0`). Only the iOS binary is Hotwire Native. The old Hotwire Native view layer was deleted in `e84f20d` and `cec8cb9`.

- **`native_app?`** — provided by `RubyNative::NativeDetection`; `request.user_agent.to_s.include?("Ruby Native")`. Consumed via `TurboNativeHelper#web_only?`
- **Layout hooks** in `app/views/layouts/application.html.erb`: `data-ruby-native` on `<html>` (line 2), `native` + `:ruby_native` stylesheets (line 22), `native-inset` class on `<main>` (line 149)
- **Gated on `unless native_app?`**: PWA update banner (line 108), feedback + support modals (line 158)
- **`native_controller.js`** — adds the `ruby-native` class to `<html>` and strips PWA controllers (`install`, `update-prompt`) when running natively
- **KNOWN BUG — `native_app?` never returns true in the app.** The gem matches on a `"Ruby Native"` user-agent substring, but the iOS binary is hand-rolled Hotwire Native and **sets no custom user agent** (no `applicationNameForUserAgent` / `customUserAgent` in any Swift file), so the WKWebView sends a default Safari UA. Every `native_app?` branch above therefore takes the *web* path inside the native shell.
- **The gem is only half-wired — decide whether to finish it or drop it.** `config/ruby_native.yml` exists (name, tint, 3 tabs, `app_id: app_cu4qa08l`), and generator setup step 2 (`stylesheet_link_tag :ruby_native`) was done, but **step 3 (`native_tabs_tag`) was never added** to any layout. The gem also ships **zero Swift/ObjC** — no `Navigator`, no bridge components — because it is designed to pair with its *own* prebuilt `ruby-native-ios` binary, not with hand-rolled Hotwire Native. It also has its own OAuth routes (`RubyNative::Auth::SessionsController`) that the app does not use; auth rides on the Devise session cookie instead. The `ruby_native` iOS binary has therefore never been built or run for this app. See "Ruby Native adoption decision" below.
- **No custom HTML top bar or overflow dropdown exists** on the Rails side. Native chrome comes from the iOS side; `SceneDelegate.swift:39` already hides the system nav bar via `navigator.rootViewController.navigationBar.isHidden = true`, which resolves the old `native_navbar_tag` clashing issue. `native_navbar_tag` is no longer called anywhere in the app.
- **No native tab bar** — `HotwireTabBarController` / `switchToTabs()` are not referenced by the current sources. Navigation is web-side only.

### Ruby Native adoption decision (open)

Two conflicting native stacks are half-present. Pick one and delete the other.

**A. Finish Ruby Native** — means writing/using a `ruby-native-ios` binary (the gem ships no Swift, so this is a new app target or a prebuilt binary), adding `native_tabs_tag` to the layout, and moving auth onto the gem's `RubyNative::Auth::SessionsController`. Then set the `Ruby Native` user agent so `native_app?` works.

**B. Drop the gem** — `bundle remove ruby_native`, delete `config/ruby_native.yml`, drop the `data-ruby-native` / `native` / `:ruby_native` stylesheet / `native-inset` / `unless native_app?` hooks from `application.html.erb` and `native_controller.js`, and keep the hand-rolled Hotwire Native app as the single native stack. Native-detection then belongs in `TurboNative::NativeApp?` (turbo-rails), which already ships and matches `Turbo Native` / the Hotwire Native UA.

Until one is chosen, `native_app?` is dead code on every request and the two stacks' assumptions are silently mixed.

## Docs
- Figma: `docs/figma_nodes.md`
- Full instructions: `CLAUDE.md`
- iOS integration: `docs/ios.md`
- Progress tracking: `docs/PROGRESS.md`
- Audit system: `docs/AUDIT_SUMMARY.md`, `docs/audit_checklist.md`
- Calendar preferences: `app/helpers/calendar_helper.rb`
- Internal docs: `/docs` (GitHub Pages)