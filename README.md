# Season — Menstrual Cycle Tracking App

A Rails 8 mobile-first PWA for tracking menstrual cycles, symptoms, and productivity based on cycle phases.

## Tech Stack

- **Ruby**: 3.4.7
- **Rails**: 8.0.5
- **Database**: PostgreSQL
- **CSS**: Tailwind CSS v4
- **Auth**: Custom cookie-based (`Authentication` concern) + Devise (password recovery only)
- **OAuth**: OmniAuth (Google, Facebook, Apple)
- **PWA**: Manifest + Service Worker
- **Background Jobs**: Solid Queue
- **Admin**: Ransack + Pagy

## Brand Colours

| Name | Hex | Usage |
|------|-----|-------|
| Primary | `#933a35` | Buttons, headings, accents |
| Secondary | `#6B6B6B` | Body text, icons |
| Background | `#FAF7F4` | Page backgrounds |
| Field BG | `#EDE1D5` | Form inputs |
| Error BG | `#FDF0EE` | Error containers |

## Routes

### Auth Flow (no bottom nav)

| Path | Method | Controller#Action | Status |
|------|--------|-------------------|--------|
| `/` | GET | home#app | ✅ Working |
| `/app` | GET | home#app | ✅ Working |
| `/loader` | GET | home#loader | ✅ Working |
| `/welcome` | GET | home#welcome | ✅ Working |
| `/registration/new` | GET | registrations#new | ✅ Working |
| `/registration` | POST | registrations#create | ✅ Working |
| `/session/new` | GET | sessions#new | ✅ Working |
| `/session` | POST | sessions#create | ✅ Working |
| `/session` | DELETE | sessions#destroy | ✅ Working |
| `/users/password/new` | GET | passwords#new (Devise) | ✅ Working |
| `/password/done` | GET | passwords#done | ⚠️ View exists, action missing |
| `/password/error/already-reset` | GET | passwords#error_already_reset | ⚠️ View exists, action missing |
| `/password/error/inbox-full` | GET | passwords#error_inbox_full | ⚠️ View exists, action missing |
| `/password/error/wrong-email` | GET | passwords#error_wrong_email | ⚠️ View exists, action missing |
| `/password/error/contact` | GET | passwords#error_contact | ⚠️ View exists, action missing |
| `/launch` | GET | launch#index | ✅ Working (orphaned — nothing links here) |

### OAuth Routes

| Path | Method | Controller#Action | Status |
|------|--------|-------------------|--------|
| `/auth/google_oauth2` | GET | OmniAuth | ✅ Ready |
| `/auth/facebook` | GET | OmniAuth | ✅ Ready |
| `/auth/apple` | GET | OmniAuth | ✅ Ready |
| `/auth/:provider/callback` | GET/POST | omniauth#callback | ✅ Working |
| `/auth/failure` | GET | omniauth#failure | ✅ Working |

### Onboarding

| Path | Method | Controller#Action | Status |
|------|--------|-------------------|--------|
| `/invite/:token` | GET | invites#show | ✅ Working |
| `/invite/:token` | PATCH | invites#update | ✅ Working |
| `/onboarding/:id` | GET | onboarding#show | ✅ Working (5 steps) |
| `/onboarding/:id` | PATCH | onboarding#update | ✅ Working — saves to DB |
| `/onboarding/finish` | GET | onboarding#finish | ✅ Working |

### Main App (with bottom nav)

| Path | Method | Controller#Action | Status |
|------|--------|-------------------|--------|
| `/calendar` | GET | calendar#index | ✅ Working |
| `/calendar_events/new` | GET | calendar_events#new | ✅ Working |
| `/calendar_events` | POST | calendar_events#create | ✅ Working |
| `/calendar_events/:id/edit` | GET | calendar_events#edit | ✅ Working |
| `/calendar_events/:id` | PATCH | calendar_events#update | ✅ Working |
| `/calendar_events/:id` | DELETE | calendar_events#destroy | ✅ Working |
| `/daily/:date` | GET | daily_view#show | ✅ Working |
| `/tracking` | GET | tracking#index | ✅ Working |
| `/tracking` | POST | tracking#create | ❌ No POST route (period logging broken) |
| `/symptoms` | GET | symptoms#index | ✅ Working |
| `/symptoms` | POST | symptoms#create | ❌ No POST route |
| `/symptoms/:id` | GET | symptoms#show | ✅ Working |
| `/superpowers` | GET | superpowers#index | ❌ Crashes (`SUPERPOWERS` constant undefined) |
| `/superpowers` | POST | superpowers#create | ❌ No POST route |
| `/superpowers/:id` | GET | superpowers#show | ✅ Working |
| `/streaks` | GET | streaks#index | ✅ Working |
| `/settings/edit` | GET | settings#edit | ✅ Working |
| `/settings` | PATCH | settings#update | ❌ Redirects to undefined `@user` route |

### Admin

| Path | Method | Controller#Action | Status |
|------|--------|-------------------|--------|
| `/admin` | GET | admin/users#index | ✅ Working (requires `admin: true` on user) |
| `/admin/users` | GET | admin/users#index | ✅ Working |
| `/admin/users/:id` | GET | admin/users#show | ✅ Working |

### System & Legal

| Path | Method | Controller#Action | Status |
|------|--------|-------------------|--------|
| `/up` | GET | rails/health#show | ✅ Working |
| `/terms` | GET | legal#terms | ✅ Working |
| `/privacy` | GET | legal#privacy | ✅ Working |
| `/manifest.json` | GET | pwa#manifest | ✅ Working |
| `/service-worker.js` | GET | pwa#service_worker | ✅ Working |

## Views

### Layouts

| File | Status | Notes |
|------|--------|-------|
| `layouts/application.html.erb` | ✅ Working | Brand colours, bottom nav (5 tabs), auth detection |
| `layouts/launch.html.erb` | ✅ Working | Bare layout for loader/app screens |
| `layouts/mailer.html.erb` | ✅ Working | Email template |
| `layouts/mailer.text.erb` | ✅ Working | Plain text email |

### Auth Views

| File | Status | Notes |
|------|--------|-------|
| `home/app.html.erb` | ✅ Working | App landing screen — logo + GET STARTED |
| `home/loader.html.erb` | ✅ Working | Stimulus loader, redirects after 2s |
| `home/welcome.html.erb` | ✅ Working | Logo, "Let's go" → signup, "I have an account" → login |
| `sessions/new.html.erb` | ✅ Working | Social OAuth buttons, email form, inline error states |
| `registrations/new.html.erb` | ✅ Working | Social OAuth buttons, email form, terms checkbox, error states |
| `passwords/new.html.erb` | ✅ Working | Change password — Devise-backed |
| `passwords/done.html.erb` | ⚠️ View only | Controller action missing |
| `passwords/error_already_reset.html.erb` | ⚠️ View only | Controller action missing |
| `passwords/error_inbox_full.html.erb` | ⚠️ View only | Controller action missing |
| `passwords/error_wrong_email.html.erb` | ⚠️ View only | Controller action missing |
| `passwords/error_contact.html.erb` | ⚠️ View only | Controller action missing |

### Onboarding Views

| File | Status | Notes |
|------|--------|-------|
| `invites/show.html.erb` | ✅ Working | Invite landing for migrating users |
| `onboarding/show.html.erb` | ✅ Working | 5-step flow — saves name, cycle, contraception, period date, language |
| `onboarding/finish.html.erb` | ✅ Working | Completion redirect screen |

### Main App Views

| File | Status | Notes |
|------|--------|-------|
| `calendar/index.html.erb` | ✅ Working | Month grid, Mon-aligned, phase colours, tracked-day checkmarks, + FAB |
| `daily_view/show.html.erb` | ✅ Working | Phase card, phase content from DB, events list |
| `tracking/index.html.erb` | ✅ Working | Period log form, symptom/superpower quick links |
| `symptoms/index.html.erb` | ✅ Working | 7-field symptom form (discharge field in DB but not form) |
| `symptoms/show.html.erb` | ✅ Working | Symptom log detail |
| `superpowers/index.html.erb` | ❌ Crashes | `SUPERPOWERS` constant undefined |
| `superpowers/show.html.erb` | ✅ Working | Superpower log detail |
| `streaks/index.html.erb` | ✅ Working | Current streak, best streak, total flames, milestones |
| `settings/edit.html.erb` | ✅ Working | Profile, language, cycle details, contraception — save broken |
| `calendar_events/new.html.erb` | ✅ Working | Add event form |
| `calendar_events/edit.html.erb` | ✅ Working | Edit event form |

### Admin Views

| File | Status | Notes |
|------|--------|-------|
| `admin/users/index.html.erb` | ✅ Working | Ransack search, Pagy pagination, CSV export |
| `admin/users/show.html.erb` | ✅ Working | User detail |

### Legal & Error Views

| File | Status | Notes |
|------|--------|-------|
| `legal/terms.html.erb` | ✅ Working | Placeholder content |
| `legal/privacy.html.erb` | ✅ Working | Placeholder content |
| `public/404.html` | ✅ Working | Custom 404 with Season branding |
| `public/500.html` | ✅ Working | Custom 500 with Season branding |

## Controllers

| Controller | Actions | Status |
|------------|---------|--------|
| `ApplicationController` | — | ✅ Includes `Authentication` concern |
| `HomeController` | app, loader, welcome | ✅ Working |
| `SessionsController` | new, create, destroy | ✅ Working + rate limiting enforced (5 attempts / 15 min) |
| `RegistrationsController` | new, create | ✅ Working |
| `OmniauthController` | callback, failure | ✅ Working |
| `PasswordsController` | new, create, edit, update + 5 error actions | ⚠️ 5 error actions undefined in controller |
| `InvitesController` | show, update | ✅ Working |
| `OnboardingController` | show, update, finish | ✅ Working — saves all 5 steps |
| `CalendarController` | index | ✅ Working |
| `CalendarEventsController` | new, create, edit, update, destroy | ✅ Working |
| `DailyViewController` | show | ✅ Working |
| `TrackingController` | index, create | ⚠️ `create` unreachable (no POST route) |
| `SymptomsController` | index, show, create | ⚠️ `create` unreachable (no POST route) |
| `SuperpowersController` | index, show, create | ❌ Crashes on `SUPERPOWERS` constant |
| `StreaksController` | index | ✅ Working |
| `SettingsController` | edit, update | ⚠️ `update` redirects to undefined route |
| `LaunchController` | index | ✅ Working (nothing links here) |
| `PwaController` | manifest, service_worker | ✅ Working |
| `LegalController` | terms, privacy | ✅ Working |
| `Admin::BaseController` | — | ✅ `require_admin` guards with `authenticated? && current_user.admin?` |
| `Admin::UsersController` | index, show | ✅ Working — Ransack + Pagy + CSV export |

## Models

### User

```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :omniauthable, omniauth_providers: [:google_oauth2, :facebook, :apple]

  has_many :cycle_entries, dependent: :destroy
  has_many :calendar_events, dependent: :destroy
  has_many :symptom_logs, dependent: :destroy
  has_many :superpower_logs, dependent: :destroy
  has_many :reminders, dependent: :destroy
  has_one :streak, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    %w[email name created_at onboarding_completed language]
  end
end
```

**Key fields**: `email`, `encrypted_password` (Devise), `name`, `cycle_length`, `period_length`, `last_period_start`, `contraception_type`, `life_stage`, `language`, `onboarding_completed`, `admin`, `google_uid`, `facebook_uid`, `apple_uid`, `invite_token`, `plan`, `birthday`, `locale`

**Auth note**: Devise manages `encrypted_password`. Custom `Authentication` concern manages sessions via encrypted cookie (`user_id`). Login uses `user.valid_password?(password)` (Devise method).

### CycleCalculatorService

Located at `app/services/cycle_calculator_service.rb`. Handles phase and season calculation for any date.

```ruby
SEASON_NAMES = {
  "menstrual" => "Winter",
  "follicular" => "Spring",
  "ovulation" => "Summer",
  "luteal" => "Autumn"
}
```

Key methods: `current_phase`, `phase_for_date(date)`, `month_data(year, month)`, `colour_for_date(date)`

## Database

### Tables

| Table | Status | Notes |
|-------|--------|-------|
| `users` | ✅ | Full schema with OAuth UIDs, admin flag, plan |
| `cycle_entries` | ✅ | Phase, season, cycle day per entry |
| `cycle_phase_contents` | ✅ | 8 rows seeded (no seed file — not reproducible after DB reset) |
| `calendar_events` | ✅ | Title, date, start/end time, category, notes |
| `symptom_logs` | ✅ | 10 tracked fields incl. discharge + notes + temperature + weight |
| `superpower_logs` | ✅ | JSONB ratings column |
| `streaks` | ✅ | current, longest, total_flames, last_tracked_date |
| `reminders` | ✅ | pill/break day reminders |

### Migrations status
All migrations: `up`. Schema version: `2026_04_07_045533`.

## Authentication

Custom cookie-based auth via `Authentication` concern:
- Session stored in encrypted cookie (httponly, secure in production, same_site: lax)
- `Current.user` thread-local accessor
- 7-day session validity
- **Rate limiting on login enforced**: 5 attempts per IP per 15 minutes (via Rails cache)
- CSRF protection enabled (Rails default)

Password recovery delegates to Devise (`PasswordsController < Devise::PasswordsController`).

### OAuth (OmniAuth)
Social login ready for Google, Facebook, Apple. Automatic user creation from OAuth data. Email required.

## Security

| Control | Status | Notes |
|---------|--------|-------|
| CSRF protection | ✅ | Rails default |
| Session cookies | ✅ | httponly, secure (prod), same_site: lax |
| Login rate limiting | ✅ | 5 attempts / 15 min per IP |
| Content Security Policy | ✅ report-only | CSP header active; flip `report_only: false` after verifying no violations |
| Ransack attribute whitelist | ✅ | Only `email, name, created_at, onboarding_completed, language` searchable |
| Admin gating | ✅ | `admin` boolean column; `require_admin` before action |
| No inline scripts | ✅ | Password toggle uses Stimulus controller, not `onclick` |
| Mass assignment | ✅ | Strong params on all write actions |

## Environment Variables

Copy `.env.template` to `.env` and configure:

```bash
# OAuth Credentials
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
FACEBOOK_APP_ID=your_facebook_app_id
FACEBOOK_APP_SECRET=your_facebook_app_secret
APPLE_CLIENT_ID=your_apple_client_id
APPLE_CLIENT_SECRET=your_apple_client_secret
```

OAuth callback URLs:
- Google: `https://yourdomain.com/auth/google_oauth2/callback`
- Facebook: `https://yourdomain.com/auth/facebook/callback`
- Apple: `https://yourdomain.com/auth/apple/callback`

## Stimulus Controllers

| File | Status | Purpose |
|------|--------|---------|
| `loader_controller.js` | ✅ Working | 2s delay then redirects (signed-in → calendar, signed-out → welcome) |
| `password_visibility_controller.js` | ✅ Working | Toggle password field visibility (eye icon swap) |

## Assets

### Images

| File | Status |
|------|--------|
| `screen1logo.png` | ✅ Taurus symbol logo |
| `Season-Wortmarke 1.svg` | ✅ Wordmark (has deprecated `xlink` — low priority) |
| `season-logo.svg` | ✅ |
| `Apple Logo.png` | ✅ OAuth button |
| `Facebook.png` | ✅ OAuth button |
| `Google.png` | ✅ OAuth button |
| `error_screens_login/` | ✅ Error state reference images |

## Screen Build Status

### Auth flow (no bottom nav)

| Screen | Status |
|--------|--------|
| App landing | ✅ Done |
| Splash / welcome | ✅ Done |
| Log in | ✅ Done (Figma design applied) |
| Log in error state | ⚠️ Inline errors exist; Turbo Stream injection pending |
| Sign up | ✅ Done (Figma design applied) |
| Sign up error state | ⚠️ Inline errors exist; Turbo Stream injection pending |
| Change password | ✅ Done (styled) |
| Invite landing page | ✅ Done |
| Onboarding step 1 — name | ✅ Done |
| Onboarding step 2 — cycle + period length | ✅ Done |
| Onboarding step 3 — contraception type | ✅ Done |
| Onboarding step 4 — last period start date | ✅ Done |
| Onboarding step 5 — language preference | ✅ Done |

### Main app (with bottom nav)

| Screen | Status |
|--------|--------|
| Calendar — monthly view | ✅ Done |
| Calendar — event detail | ✅ Done |
| Calendar — add event form | ✅ Done |
| Daily tracking screen | ✅ Done |
| Symptoms screen | ⚠️ Done — discharge field in DB but not form |
| Superpower screen | ❌ Crashes (`SUPERPOWERS` constant) |
| Period entry screen | ❌ No POST `/tracking` route |
| Daily forecast / tips | ✅ Done |
| Appointments view | ✅ Done |
| Streaks screen | ✅ Done |
| Settings screen | ⚠️ View done — save broken |

## Known Issues

### Critical (crashes / broken flows)

| # | Issue | File |
|---|-------|------|
| C1 | `SUPERPOWERS` constant undefined — `/superpowers` crashes | `app/controllers/superpowers_controller.rb` |
| C2 | 5 password error actions in routes/views but not in controller | `app/controllers/passwords_controller.rb` |
| C3 | `SettingsController#update` redirects to `@user` — no `users` route exists | `app/controllers/settings_controller.rb` |
| C4 | No `POST /tracking` route — period logging form goes nowhere | `config/routes.rb` |

### High

| # | Issue | File |
|---|-------|------|
| H1 | Symptoms and superpowers `create` actions have no POST routes | `config/routes.rb` |
| H2 | `cycle_phase_contents` data has no seed file — not reproducible after DB reset | — |

### Medium

| # | Issue | File |
|---|-------|------|
| M1 | `discharge` symptom field missing from symptoms form (column exists in DB) | `app/views/symptoms/index.html.erb` |
| M2 | CSP in report-only mode — needs flip to enforcement after verifying no violations | `config/initializers/content_security_policy.rb` |
| M3 | Loader uses fixed 428×926px dimensions — not fully responsive | `app/views/home/loader.html.erb` |

## Getting Started

```bash
# Requires Ruby 3.4.7 (rbenv)
rbenv install 3.4.7

# Install dependencies
bundle install

# Set up database
RBENV_VERSION=3.4.7 bundle exec rails db:create db:schema:load

# Copy and configure environment variables
cp .env.template .env

# Start server
bin/dev
```

> **Note**: Use `RBENV_VERSION=3.4.7 bundle exec rails` for all Rails commands if your shell defaults to an older Ruby version.


## Brand Colours

| Name | Hex | Usage |
|------|-----|-------|
| Primary | `#933a35` | Buttons, headings, accents |
| Secondary | `#6B6B6B` | Body text, icons |
| Background | `#FAF7F4` | Page backgrounds |
| Field BG | `#EDE1D5` | Form inputs |
| Error BG | `#FDF0EE` | Error containers |

## Routes

### Auth Flow (no bottom nav)

| Path | Method | Controller#Action | Status |
|------|--------|-------------------|--------|
| `/` | GET | home#app | ✅ Working |
| `/app` | GET | home#app | ✅ Working |
| `/loader` | GET | home#loader | ✅ Working |
| `/welcome` | GET | home#welcome | ✅ Working |
| `/registration/new` | GET | registrations#new | ✅ Working |
| `/registration` | POST | registrations#create | ✅ Working |
| `/session/new` | GET | sessions#new | ✅ Working |
| `/session` | POST | sessions#create | ✅ Working |
| `/session` | DELETE | sessions#destroy | ✅ Working |
| `/users/password/new` | GET | passwords#new (Devise) | ✅ Working |
| `/password/done` | GET | passwords#done | ⚠️ View exists, action missing |
| `/password/error/already-reset` | GET | passwords#error_already_reset | ⚠️ View exists, action missing |
| `/password/error/inbox-full` | GET | passwords#error_inbox_full | ⚠️ View exists, action missing |
| `/password/error/wrong-email` | GET | passwords#error_wrong_email | ⚠️ View exists, action missing |
| `/password/error/contact` | GET | passwords#error_contact | ⚠️ View exists, action missing |
| `/launch` | GET | launch#index | ✅ Working (orphaned — nothing links here) |

### OAuth Routes

| Path | Method | Controller#Action | Status |
|------|--------|-------------------|--------|
| `/auth/google_oauth2` | GET | OmniAuth | ✅ Ready |
| `/auth/facebook` | GET | OmniAuth | ✅ Ready |
| `/auth/apple` | GET | OmniAuth | ✅ Ready |
| `/auth/:provider/callback` | GET/POST | omniauth#callback | ✅ Working |
| `/auth/failure` | GET | omniauth#failure | ✅ Working |

### Onboarding

| Path | Method | Controller#Action | Status |
|------|--------|-------------------|--------|
| `/invite/:token` | GET | invites#show | ✅ Working |
| `/invite/:token` | PATCH | invites#update | ✅ Working |
| `/onboarding/:id` | GET | onboarding#show | ✅ Working (5 steps) |
| `/onboarding/:id` | PATCH | onboarding#update | ✅ Working — saves to DB |
| `/onboarding/finish` | GET | onboarding#finish | ✅ Working |

### Main App (with bottom nav)

| Path | Method | Controller#Action | Status |
|------|--------|-------------------|--------|
| `/calendar` | GET | calendar#index | ✅ Working |
| `/calendar_events/new` | GET | calendar_events#new | ✅ Working |
| `/calendar_events` | POST | calendar_events#create | ✅ Working |
| `/calendar_events/:id/edit` | GET | calendar_events#edit | ✅ Working |
| `/calendar_events/:id` | PATCH | calendar_events#update | ✅ Working |
| `/calendar_events/:id` | DELETE | calendar_events#destroy | ✅ Working |
| `/daily/:date` | GET | daily_view#show | ✅ Working |
| `/tracking` | GET | tracking#index | ✅ Working |
| `/tracking` | POST | tracking#create | ❌ No route (period logging broken) |
| `/symptoms` | GET | symptoms#index | ✅ Working |
| `/symptoms` | POST | symptoms#create | ❌ No route |
| `/symptoms/:id` | GET | symptoms#show | ✅ Working |
| `/superpowers` | GET | superpowers#index | ❌ Crashes (`SUPERPOWERS` constant undefined) |
| `/superpowers` | POST | superpowers#create | ❌ No route |
| `/superpowers/:id` | GET | superpowers#show | ✅ Working |
| `/streaks` | GET | streaks#index | ✅ Working |
| `/settings/edit` | GET | settings#edit | ✅ Working |
| `/settings` | PATCH | settings#update | ❌ Crashes (redirects to undefined route) |

### Admin

| Path | Method | Controller#Action | Status |
|------|--------|-------------------|--------|
| `/admin` | GET | admin/users#index | ❌ Crashes (`authenticate_user!` + missing `Pagy::Backend`) |
| `/admin/users` | GET | admin/users#index | ❌ Same |
| `/admin/users/:id` | GET | admin/users#show | ❌ Same |

### System & Legal

| Path | Method | Controller#Action | Status |
|------|--------|-------------------|--------|
| `/up` | GET | rails/health#show | ✅ Working |
| `/terms` | GET | legal#terms | ✅ Working |
| `/privacy` | GET | legal#privacy | ✅ Working |
| `/manifest.json` | GET | pwa#manifest | ✅ Working |
| `/service-worker.js` | GET | pwa#service_worker | ✅ Working |

## Views

### Layouts

| File | Status | Notes |
|------|--------|-------|
| `layouts/application.html.erb` | ✅ Working | Brand colours, bottom nav (5 tabs), auth detection |
| `layouts/launch.html.erb` | ✅ Working | Bare layout for loader/app screens |
| `layouts/mailer.html.erb` | ✅ Working | Email template |
| `layouts/mailer.text.erb` | ✅ Working | Plain text email |

### Auth Views

| File | Status | Notes |
|------|--------|-------|
| `home/app.html.erb` | ✅ Working | App landing screen — logo + GET STARTED (links to login, not signup) |
| `home/loader.html.erb` | ✅ Working | Stimulus loader, redirects after 2s |
| `home/welcome.html.erb` | ✅ Working | Logo, "Let's go" → signup, "I have an account" → login |
| `sessions/new.html.erb` | ✅ Working | Social OAuth buttons, email form, inline error states |
| `registrations/new.html.erb` | ✅ Working | Social OAuth buttons, email form, terms checkbox, error states |
| `passwords/new.html.erb` | ✅ Working | Change password — Devise-backed |
| `passwords/done.html.erb` | ⚠️ View only | Controller action missing |
| `passwords/error_already_reset.html.erb` | ⚠️ View only | Controller action missing |
| `passwords/error_inbox_full.html.erb` | ⚠️ View only | Controller action missing |
| `passwords/error_wrong_email.html.erb` | ⚠️ View only | Controller action missing |
| `passwords/error_contact.html.erb` | ⚠️ View only | Controller action missing |

### Onboarding Views

| File | Status | Notes |
|------|--------|-------|
| `invites/show.html.erb` | ✅ Working | Invite landing for migrating users |
| `onboarding/show.html.erb` | ✅ Working | 5-step flow — saves name, cycle, contraception, period date, language |
| `onboarding/finish.html.erb` | ✅ Working | Completion redirect screen |

### Main App Views

| File | Status | Notes |
|------|--------|-------|
| `calendar/index.html.erb` | ✅ Working | Month grid, Mon-aligned, phase colours, tracked-day checkmarks, + FAB |
| `daily_view/show.html.erb` | ✅ Working | Phase card, phase content from DB, events list |
| `tracking/index.html.erb` | ✅ Working | Period log form, symptom/superpower quick links |
| `symptoms/index.html.erb` | ✅ Working | 7-field symptom form (missing `discharge`) |
| `symptoms/show.html.erb` | ✅ Working | Symptom log detail |
| `superpowers/index.html.erb` | ❌ Crashes | `SUPERPOWERS` constant undefined |
| `superpowers/show.html.erb` | ✅ Working | Superpower log detail |
| `streaks/index.html.erb` | ✅ Working | Current streak, best streak, total flames, milestones |
| `settings/edit.html.erb` | ✅ Working | Profile, language, cycle details, contraception — save broken |
| `calendar_events/new.html.erb` | ✅ Working | Add event form |
| `calendar_events/edit.html.erb` | ✅ Working | Edit event form |

### Admin Views

| File | Status | Notes |
|------|--------|-------|
| `admin/users/index.html.erb` | ⚠️ View exists | Controller crashes before reaching it |
| `admin/users/show.html.erb` | ⚠️ View exists | Controller crashes before reaching it |

### Legal & Error Views

| File | Status | Notes |
|------|--------|-------|
| `legal/terms.html.erb` | ✅ Working | Placeholder content |
| `legal/privacy.html.erb` | ✅ Working | Placeholder content |
| `public/404.html` | ✅ Working | Custom 404 with Season branding |
| `public/500.html` | ✅ Working | Custom 500 with Season branding |

## Controllers

| Controller | Actions | Status |
|------------|---------|--------|
| `ApplicationController` | — | ✅ Includes `Authentication` concern |
| `HomeController` | app, loader, welcome | ✅ Working |
| `SessionsController` | new, create, destroy | ✅ Working + rate limiting (5 attempts / 15 min) |
| `RegistrationsController` | new, create | ✅ Working |
| `OmniauthController` | callback, failure | ✅ Working |
| `PasswordsController` | new, create, edit, update + 5 error actions | ⚠️ Inherits Devise; 5 error actions undefined |
| `InvitesController` | show, update | ✅ Working |
| `OnboardingController` | show, update, finish | ✅ Working — saves all 5 steps |
| `CalendarController` | index | ✅ Working |
| `CalendarEventsController` | new, create, edit, update, destroy | ✅ Working |
| `DailyViewController` | show | ✅ Working |
| `TrackingController` | index, create | ⚠️ `create` unreachable (no POST route) |
| `SymptomsController` | index, show, create | ⚠️ `create` unreachable (no POST route) |
| `SuperpowersController` | index, show, create | ❌ Crashes on `SUPERPOWERS` constant |
| `StreaksController` | index | ✅ Working |
| `SettingsController` | edit, update | ⚠️ `update` redirects to undefined route |
| `LaunchController` | index | ✅ Working (nothing links here) |
| `PwaController` | manifest, service_worker | ✅ Working |
| `LegalController` | terms, privacy | ✅ Working |
| `Admin::BaseController` | — | ❌ Calls `authenticate_user!` (undefined) |
| `Admin::UsersController` | index, show | ❌ Blocked by BaseController + missing `Pagy::Backend` |

## Models

### User

```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :omniauthable, omniauth_providers: [:google_oauth2, :facebook, :apple]

  has_many :cycle_entries, dependent: :destroy
  has_many :calendar_events, dependent: :destroy
  has_many :symptom_logs, dependent: :destroy
  has_many :superpower_logs, dependent: :destroy
  has_many :reminders, dependent: :destroy
  has_one :streak, dependent: :destroy
end
```

**Key fields**: `email`, `encrypted_password` (Devise), `name`, `cycle_length`, `period_length`, `last_period_start`, `contraception_type`, `life_stage`, `language`, `onboarding_completed`, `google_uid`, `facebook_uid`, `apple_uid`, `invite_token`

**Auth note**: Devise manages `encrypted_password`. Custom `Authentication` concern manages sessions via encrypted cookie (`user_id`). Login uses `user.valid_password?(password)` (Devise method).

### CycleCalculatorService

Located at `app/services/cycle_calculator_service.rb`. Handles phase and season calculation for any date.

```ruby
SEASON_NAMES = {
  "menstrual" => "Winter",
  "follicular" => "Spring",
  "ovulation" => "Summer",
  "luteal" => "Autumn"
}
```

Key methods: `current_phase`, `phase_for_date(date)`, `month_data(year, month)`, `colour_for_date(date)`

## Database

### Tables

| Table | Status | Notes |
|-------|--------|-------|
| `users` | ✅ | Full schema with OAuth UIDs |
| `cycle_entries` | ✅ | Phase, season, cycle day per entry |
| `cycle_phase_contents` | ✅ | 8 rows seeded (no seed file — not reproducible) |
| `calendar_events` | ✅ | Title, date, start/end time, category, notes |
| `symptom_logs` | ✅ | 10 tracked fields + notes + temperature + weight |
| `superpower_logs` | ✅ | JSONB ratings column |
| `streaks` | ✅ | current, longest, total_flames, last_tracked_date |
| `reminders` | ✅ | pill/break day reminders |

### Migrations status
All 5 migrations: `up`. Schema version: `2026_04_06_211733`.

## Authentication

Custom cookie-based auth via `Authentication` concern:
- Session stored in encrypted cookie (httponly, secure, same_site: lax)
- `Current.user` thread-local accessor
- 7-day session validity
- Rate limiting on login: 5 attempts per 15 minutes
- CSRF protection enabled

Password recovery delegates to Devise (`PasswordsController < Devise::PasswordsController`).

### OAuth (OmniAuth)
Social login ready for Google, Facebook, Apple. Automatic user creation from OAuth data. Email required.

## Environment Variables

Copy `.env.template` to `.env` and configure:

```bash
# OAuth Credentials
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
FACEBOOK_APP_ID=your_facebook_app_id
FACEBOOK_APP_SECRET=your_facebook_app_secret
APPLE_CLIENT_ID=your_apple_client_id
APPLE_CLIENT_SECRET=your_apple_client_secret
```

OAuth callback URLs:
- Google: `https://yourdomain.com/auth/google_oauth2/callback`
- Facebook: `https://yourdomain.com/auth/facebook/callback`
- Apple: `https://yourdomain.com/auth/apple/callback`

## Stimulus Controllers

| File | Status | Purpose |
|------|--------|---------|
| `loader_controller.js` | ✅ Working | 2s delay then redirects (signed-in → calendar, signed-out → welcome) |
| `password_visibility_controller.js` | ✅ Working | Toggle password field visibility |

## Assets

### Images

| File | Status |
|------|--------|
| `screen1logo.png` | ✅ Taurus symbol logo |
| `Season-Wortmarke 1.svg` | ✅ Wordmark (has deprecated `xlink` — low priority) |
| `season-logo.svg` | ✅ |
| `Apple Logo.png` | ✅ OAuth button |
| `Facebook.png` | ✅ OAuth button |
| `Google.png` | ✅ OAuth button |
| `error_screens_login/` | ✅ Error state reference images |

## Known Issues

### Critical (crashes)

| # | Issue | File |
|---|-------|------|
| C1 | `Admin::BaseController` calls `authenticate_user!` — undefined, crashes `/admin` | `app/controllers/admin/base_controller.rb` |
| C2 | `SUPERPOWERS` constant undefined — `/superpowers` crashes | `app/controllers/superpowers_controller.rb` |
| C3 | 5 password error actions defined in routes/views but not in controller | `app/controllers/passwords_controller.rb` |
| C4 | `SettingsController#update` redirects to `@user` — no `users` route exists | `app/controllers/settings_controller.rb` |
| C5 | No `POST /tracking` route — period logging form goes nowhere | `config/routes.rb` |

### High

| # | Issue | File |
|---|-------|------|
| H1 | Admin crashes: `Pagy::Backend` not included anywhere | `app/controllers/admin/users_controller.rb` |
| H2 | Symptoms and superpowers `create` actions have no POST routes | `config/routes.rb` |
| H3 | `cycle_phase_contents` data has no seed file — not reproducible after DB reset | — |

### Medium

| # | Issue | File |
|---|-------|------|
| M1 | `discharge` symptom field missing from symptoms form | `app/views/symptoms/index.html.erb` |
| M2 | App landing CTA ("GET STARTED") links to login instead of signup | `app/views/home/app.html.erb` |
| M3 | Loader uses fixed pixel dimensions (428×926) — not fully responsive | `app/views/home/loader.html.erb` |

## Getting Started

```bash
# Requires Ruby 3.4.7 (rbenv)
rbenv install 3.4.7

# Install dependencies
bundle install

# Set up database
RBENV_VERSION=3.4.7 bundle exec rails db:create db:schema:load

# Copy and configure environment variables
cp .env.template .env

# Start server
bin/dev
```

> **Note**: Use `RBENV_VERSION=3.4.7 bundle exec rails` for all Rails commands if your shell defaults to an older Ruby version.
