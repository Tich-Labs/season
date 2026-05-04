# AGENT INSTRUCTIONS — READ BEFORE DOING ANYTHING
# This file applies to ALL AI agents: Claude Code, OpenCode, Cursor, Copilot
# Follow every instruction in this file exactly.

## Figma Nodes Source of Truth

Design reference: `docs/figma_nodes.md`

### Milestones Overview
| Milestone | Screens | Figma Nodes Section | Status |
|-----------|---------|----------------------|--------|
| M1 | 43 | Signing In and Onboarding | ✅ Built |
| M2 | 32 | Calendar with Basic Cycle & Display | ✅ Built |
| M3 | 64 | Tracking / Learn (12068-* nodes) | ✅ Built |
| M4 | 60 | Forecasting and Appointments | ✅ Built |
| M5 | 60 | Birth Control and Other Reminders | ✅ Built |
| M6 | 24 | Gamification & Scoring Flames | ❌ Not built |
| M7 | 17 | Onboarding & Feedback | ✅ Built |

### Current Status

- M1, M2, M3, M4, M5, M7: All built
- M6: Not in scope
- M2 remaining: OAuth credentials, accessibility fixes
- M2 complete: SMTP/email (Resend), admin enhancements, LaunchSignup system
- See docs/AUDIT-2026-04-10.md for full status.

### M2 Summary (Calendar & Settings)
- Calendar now supports user-toggleable display preferences (appointments, cycle days, moon phases, holidays, week numbers)
- Settings calendar page: all 5 toggles save to `users` table and persist correctly
- `CalendarController` loads preferences via `load_calendar_preferences` and filters data accordingly
- `CalendarHelper` provides `holidays_for_month(year, month)` and `iso_week_number(date)`
- `_day_cell.html.erb` respects `show_holidays` and `show_week_numbers` locals
- Fields added: `show_moonphases`, `show_holidays`, `show_week_numbers` (boolean, default nil)
- Rubocop/erb_lint clean on all modified files

### M3 Summary (Tracking / Learn)

Figma audit revealed 64 nodes break down to ~8 unique screens — the rest are state variants, flow arrows, and already-built views. All unique screens are now built:

- `/informations` + `/informations/:phase` (4 phases) — phase education
- `/tracking` — Self Analysis overview (donut wheel, cycle day strip, navigation)
- `/tracking/period` — Period entry / edit (calendar date picker, GET + PATCH)
- `/symptoms` — Symptom log (Mood / Physical / Mental accordion, notes, temperature, weight)
- `/symptoms/:id`, `/symptoms/discharge` — symptom detail and discharge guide
- `/superpowers`, `/superpowers/:id` — superpower tracking
- `/streaks` — streak display

## Brand Colours

Primary: **#933a35** (from Figma — not #7D3030)
Secondary: #6B6B6B
Background: #FAF7F4
White: #FFFFFF
Field background: **#EDE1D5** (not #F5EDE8 — match Figma exactly)
Error background: #FDF0EE
Muted pink: #D18D83

## Figma source of truth

**Figma file:** https://www.figma.com/design/Vi7qdepuk2lWGl4TWXbedb/SEASON.Vision-App-2026--Copy-

Primary brand colour is **#933a35** (from Figma).
All references must use this colour exactly.

### When building any screen:
1. Always fetch Figma design context first using the MCP server before writing any code
2. Figma is the source of truth for:
   - Colours (use exact hex from Figma)
   - Spacing and layout
   - Typography sizes and weights
   - Component hierarchy
   - Copy/text content
3. Match Figma exactly then convert to Tailwind equivalents
4. Never hardcode colours not in Figma

## Screen inventory — full list

### Auth flow (no bottom nav) ✅ ALL DONE
- App landing screen (`/`) - countdown/loader
- Splash / welcome screen (`/welcome`)
- Sign up (`/registration/new`)
- Log in (`/session/new`)
- Password recovery (`/users/password/new`)
- Password reset (`/users/password/edit`)
- Password done (`/password/done`)
- Password error pages (`/password/error/*`)
- Invite landing (`/invite/:token`)
- Onboarding steps 1-11 (`/onboarding/:id`)
- Onboarding finish (`/onboarding/finish`)

### Main app (with top bar + burger menu) ✅ ALL DONE
- Calendar monthly (`/calendar`)
- Calendar weekly (`/calendar/weekly`)
- Calendar appointments (`/calendar/appointments`)
- Calendar event add (`/calendar_events/new`)
- Calendar event edit (`/calendar_events/:id/edit`)
- Daily view (`/daily/:date`)
- Tracking/period entry (`/tracking`)
- Symptoms list & detail (`/symptoms`, `/symptoms/:id`)
- Superpowers list & detail (`/superpowers`, `/superpowers/:id`)
- Streaks (`/streaks`)
- Settings main (`/settings/edit`)
- Settings profile (`/settings/profile`)
- Settings subscriptions (`/settings/subscriptions`)
- Settings calendar (`/settings/calendar`)
- Settings notifications (`/settings/notifications`)

### M3: Tracking / Learn (64 screens) ✅ BUILT

- `/informations` — Phase overview (index)
- `/informations/:phase` — Phase detail (4 pages: menstrual, follicular, ovulation, luteal)
- `/tracking` — Self Analysis (donut wheel, cycle strip, streak, nav to symptoms/superpowers)
- `/tracking/period` — Period entry / edit (monthly calendar picker, GET + PATCH)
- `/symptoms` — Symptom log with Mood / Physical / Mental accordion, notes, temperature, weight
- `/symptoms/:id` — Symptom detail
- `/symptoms/discharge` — Discharge guide
- `/superpowers` — Superpower list
- `/superpowers/:id` — Superpower detail
- `/streaks` — Streak display

Note: 64 Figma nodes include ~30 state variants of the Analyse/symptom screen, ~6 profile/tracking overview variants, flow arrows, and connector labels — not 64 distinct screens.

### Public / Launch
- Launch / countdown (`/launch`) ✅ DONE
- Terms (`/terms`) ✅ DONE
- Privacy (`/privacy`) ✅ DONE

### Error states ✅ ALL DONE
- Log in error (inline, no redirect)
- Sign up error (inline, no redirect)
- General 404
- General 500

## Admin panel

Admin lives at `/admin/*`, gated by `User#admin?`. Layout: `app/views/layouts/admin.html.erb`.

### Admin routes
- `GET /admin` → Users list (root)
- `GET /admin/users/:id` → User detail (includes cycle stats: avg cycle length, period history, next period prediction)
- `GET /admin/inbox` → All messages (overview)
- `GET /admin/inbox/feedback` → Feedback only
- `GET /admin/inbox/bugs` → Bug reports only
- `GET /admin/inbox/support` → Support only
- `GET /admin/inbox/export_csv` → CSV download
- `GET /admin/launch_signups` → Waitlist list
- `GET /admin/launch_signups/export_csv` → CSV download
- `GET /admin/login` → Admin-only login (separate from app auth)

### Admin sidebar rules
- All active states use `bg-[#7a2f2a] text-white` — never use blue/red/purple per section
- Inbox is a direct link (= All Messages). Sub-items Feedback/Bugs/Support always visible below it
- Count badges use `rounded-full px-2` for breathing room
- No JS toggles in the sidebar

## Asset naming conventions

All image and asset files placed in `app/assets/images/` must follow these rules:

- **Lowercase only** — no uppercase letters
- **Hyphens instead of spaces** — `season-logo.svg` not `season logo.svg`
- **No special characters** — no parentheses, dots (except extension), or punctuation
- **Descriptive, short names** — `errorscreen-wrong-email.png` not `Errorscreen - wrong email.png`

**Why**: Propshaft fails to digest asset filenames with spaces during `assets:precompile` on Render, causing 404s in production.

Always use `image_tag` (never hardcoded `<img src="...">`) so Propshaft handles digest fingerprinting.

## Error screen requirements

All error states must:
- Show inline errors NOT page-level redirects
- Use Turbo Stream to inject errors without full page reload
- Error text colour: **#933a35**
- Error container: `bg-[#FDF0EE] rounded-xl px-4 py-3 text-sm text-[#933a35]`
- Field with error: `border border-[#933a35]` on the input (add border class conditionally)
- Devise errors render via `devise/shared/error_messages` partial
- Custom error partial styling must match above

## Auth flow requirements

- **Email confirmation (`:confirmable`)** is fully implemented:
  - Sign up → redirect to `/registration/check_email` ("Check your inbox" page)
  - User clicks confirmation link in email → `ConfirmationsController#show` auto-logs in → redirects to onboarding
  - OmniAuth (Google/Apple/Facebook) bypasses confirmation — provider already verified email
  - Unconfirmed user trying to sign in → shows `:unconfirmed` error with resend link
  - Expired/reused confirmation link → redirect to `/users/confirmation/new` with alert
- **`devise_parameter_sanitizer`** configured in `ApplicationController` for `sign_up` and `account_update`
- **Rate limiting**: 5 attempts per 15 min in production (disabled in development)

## i18n rules

- **MVP language is English.** Do not hardcode German text in views.
- All user-facing strings must use `t()` helpers so German translations work automatically.
- Auth views already use `t()` — maintain this pattern in any new views.
- Onboarding strings are hardcoded English (known debt, M2 target).
- Locale files: `config/locales/en.yml` and `config/locales/de.yml`.

## Database rules

- App uses **PostgreSQL only** — no SQLite in any environment.
- `db/development.sqlite3` and `db/test.sqlite3` are gitignored and should not exist.
- `config/master.key` is gitignored — never commit it. Get it from the team password manager.
- `SECRET_KEY_BASE`: Render auto-generates it. Local dev reads from `credentials.yml.enc`.
  The two values do not need to match — this is correct and expected.

## Credentials & secrets

- `config/master.key` — gitignored, never committed, required locally to decrypt credentials
- `config/credentials.yml.enc` — committed, safe (encrypted)
- On Render: set `RAILS_MASTER_KEY` manually in the dashboard (it is `sync: false` in render.yaml)
- `SECRET_KEY_BASE` on Render: auto-generated via `generateValue: true`, do not set manually

## Known gotchas

- **RuboCop / IDE warnings on ERB files**: The Ruby parser misreads `<%` and `%>` as comparison operators and reports false-positive warnings. These are not real errors — ignore them.
- **`Admin::FeedbacksController` was deleted**: Feedback is now handled entirely by `Admin::InboxController`. Do not recreate the feedbacks controller.
- **`User#current_phase`** — may return nil for new users with no cycle data. Always guard with `|| "Unknown"` in views.
- **`current_user.onboarding_completed?`** — use this (not `last_period_start.present?`) to check if a user has finished onboarding.
- **Resend mailer**: use the gem adapter — `config.action_mailer.delivery_method = :resend` in `production.rb`. The API key must be set via `config/initializers/resend.rb` (`Resend.api_key = ENV["RESEND_API_KEY"]`). Do NOT use raw SMTP with `smtp.resend.com` — it was removed.
- **OmniAuth (Google/Facebook/Apple)**: configured once via `config.omniauth` in `config/initializers/devise.rb` only. A separate `config/initializers/omniauth.rb` was deleted — do not recreate it. **OAuth is fully built — just add credentials to Render dashboard.** See docs/app_documentation.md for step-by-step setup.
- **Password reset — expired/invalid token**: redirects to `password_error_link_expired_path` (`/password/error/link-expired`). Do not use `password_error_already_reset_path` for this case — that page is only for rate-limit messaging.
- **Password reset form**: has two fields (`password` + `password_confirmation`). Validation errors re-render the form inline (not redirect). The token is passed via a hidden field.

## Styling Standard (Tailwind)

**IMPORTANT**: All views MUST use Tailwind classes - no inline `style=""` attributes.

### Tailwind Config (`config/tailwind.config.js`)

Brand colors are defined as CSS variables - use these classes:
- `text-brand-primary` / `bg-brand-primary` → #933a35
- `text-brand-secondary` / `bg-brand-secondary` → #6B6B6B
- `text-brand-background` / `bg-brand-background` → #FAF7F4
- `text-brand-field` / `bg-brand-field` → #EDE1D5
- `text-brand-error` / `bg-brand-error` → #FDF0EE
- `text-brand-muted` / `bg-brand-muted` → #D18D83
- `text-brand-dark` / `bg-brand-dark` → #3d2b28

Phase colors:
- `text-phase-menstrual` / `bg-phase-menstrual` → #933a35
- `text-phase-follicular` / `bg-phase-follicular` → #D18D83
- `text-phase-ovulation` / `bg-phase-ovulation` → #F5C6AD
- `text-phase-luteal` / `bg-phase-luteal` → #EDE1D5

### Container Standard
- All main views: `max-w-app mx-auto px-4` (430px max-width, centered)
- Page wrapper: `min-h-screen pb-20` (accounts for bottom nav)

### Common Patterns
```erb
<!-- Page wrapper -->
<div class="bg-brand-background min-h-screen pb-20">
  <div class="max-w-app mx-auto px-4">

<!-- Card -->
<div class="bg-white rounded-2xl p-5">

<!-- Section header -->
<h2 class="text-lg font-bold text-brand-dark mb-4">

<!-- Form field -->
<input class="w-full bg-brand-field rounded-xl px-4 py-3 text-brand-dark">

<!-- Primary button -->
<button class="w-full bg-brand-primary text-white rounded-xl py-3.5 font-semibold">
```

### What NOT to do
- No `style="..."` in views (except dynamic colors from phase calculations)
- No arbitrary values like `text-[#933a35]` - use `text-brand-primary`
- No hex colors directly - always use the brand classes

### When to use dynamic styles
- Phase colors that come from `CycleCalculatorService::PHASE_META`
- Conditional logic (e.g., selected state colors)

Example:
```erb
<div class="rounded-xl p-4" style="background:<%= phase_colour %>;">
```
This is acceptable because the color is dynamic and comes from a service.
