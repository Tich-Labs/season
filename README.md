# Season V2

## What is Season

Season is a women's cycle tracking progressive web app (PWA) built on Rails 8 with Hotwire. It helps users understand their menstrual cycle through a seasonal metaphor (Winter/Spring/Summer/Autumn), track symptoms and superpowers daily, view their cycle calendar, and build tracking streaks. The app launched 7 April 2026 with an invite-only beta for 150 migrating users.

---

## Tech Stack

| Layer | Tech | Version |
|-------|------|---------|
| Language | Ruby | 3.4.7 |
| Framework | Rails | 8.0.5 |
| Database | PostgreSQL | latest |
| CSS | Tailwind CSS | ~3.3.1 (via tailwindcss-rails) |
| JS | Hotwire (Turbo + Stimulus) | turbo-rails / stimulus-rails |
| Auth | Custom cookie session + Devise (passwords only) | devise |
| Background Jobs | Solid Queue | solid_queue |
| Caching | Solid Cache | solid_cache |
| WebSockets | Solid Cable | solid_cable |
| Error tracking | Sentry | sentry-ruby / sentry-rails |
| Payments | Stripe | stripe (wired, not active) |
| Admin | Ransack + Pagy | ransack / pagy |
| OmniAuth | Google, Facebook, Apple | omniauth-google-oauth2, omniauth-facebook, omniauth-apple |

---

## Architecture

- **PWA mobile-first** — 390px base, max-w-md layout container throughout. Turbo Native (iOS/Android) roadmap.
- **Auth** — Custom cookie-based `Authentication` concern in `app/controllers/concerns/authentication.rb`. Devise is used only for password recovery emails. Sessions are encrypted cookies with 7-day expiry.
- **Cycle logic** — `CycleCalculatorService` (`app/services/cycle_calculator_service.rb`). Single source of truth for phase, season, cycle day, and calendar colour data.
- **Phase content** — `CyclePhaseContent` model, seeded for en/de x 4 phases. Stores superpower, mood, sport, nutrition, and care text per phase/locale.
- **i18n** — English default, German available. All user-facing strings must go through `t()` helpers. Locales: `config/locales/en.yml` + `config/locales/de.yml`.
- **Admin** — `admin/` namespace, gated by `User#admin?` boolean. Lists and shows users.

---

## Milestone Status

| Milestone | Status | Notes |
|-----------|--------|-------|
| M1 Auth + Onboarding | Complete | 5-step onboarding, invite flow, custom session auth |
| M2 Calendar | Complete | Monthly view, cycle phase colours, event creation |
| M3 Tracking | Complete | Symptoms, superpowers, period start logging |
| M4 Daily View | Complete | Day-detail screen at /daily/:date |
| M5 Reminders | Post-launch | Schema exists (reminders table), no UI yet |
| M6 Streaks | Complete | Flame streak, milestones, longest streak |
| M7 Onboarding Tour | Post-launch | No tour overlay built yet |
| M8 Monetisation | Post-launch | Stripe gem added, paywall not wired |

---

## Setup

### Prerequisites

- Ruby 3.4.7 (use rbenv or asdf)
- PostgreSQL running locally
- Node.js (for Tailwind build watcher)

### Installation

```bash
git clone <repo>
cd season

# Install Ruby deps
bundle install

# Copy env template and fill in values
cp .env.template .env

# Create DB, load schema, seed phase content
bin/rails db:create db:schema:load db:seed

# Start dev server
bin/dev
```

### Environment Variables

| Variable | Required | Notes |
|----------|----------|-------|
| `RAILS_MASTER_KEY` | Yes | Decrypts config/credentials.yml.enc |
| `DATABASE_URL` | Production only | Render PostgreSQL URL |
| `GOOGLE_CLIENT_ID` | OAuth | For Google Sign-In |
| `GOOGLE_CLIENT_SECRET` | OAuth | For Google Sign-In |
| `FACEBOOK_APP_ID` | OAuth | For Facebook Sign-In |
| `FACEBOOK_APP_SECRET` | OAuth | For Facebook Sign-In |
| `APPLE_CLIENT_ID` | OAuth | For Apple Sign-In |
| `APPLE_TEAM_ID` | OAuth | For Apple Sign-In |
| `APPLE_KEY_ID` | OAuth | For Apple Sign-In |
| `APPLE_PRIVATE_KEY` | OAuth | PEM format |
| `SENTRY_DSN` | Production | Error tracking |
| `STRIPE_SECRET_KEY` | Post-launch | Payments |

---

## Screens

### Auth Flow (no bottom nav)

| Screen | Route | Auth Required |
|--------|-------|---------------|
| Loader / Splash | `/` and `/loader` | No |
| Welcome | `/welcome` | No |
| Sign Up | `/registration/new` | No |
| Log In | `/session/new` | No |
| Forgot Password | `/users/password/new` | No |
| Reset Password | `/users/password/edit` | No |
| Password Done | `/password/done` | No |
| Invite Landing | `/invite/:token` | No |
| Onboarding Step 1-5 | `/onboarding/:id` | Yes |

### Main App (with top bar + burger menu)

| Screen | Route | Auth Required |
|--------|-------|---------------|
| Calendar | `/calendar` | Yes |
| Add Calendar Event | `/calendar_events/new` | Yes |
| Edit Calendar Event | `/calendar_events/:id/edit` | Yes |
| Daily View | `/daily/:date` | Yes |
| Tracking (period) | `/tracking` | Yes |
| Symptoms | `/symptoms` | Yes |
| Superpowers | `/superpowers` | Yes |
| Streaks | `/streaks` | Yes |
| Settings (main) | `/settings/edit` | Yes |
| Settings Profile | `/settings/profile` | Yes |
| Settings Subscriptions | `/settings/subscriptions` | Yes |
| Settings Calendar | `/settings/calendar` | Yes |

### Legal / Support

| Screen | Route | Auth Required |
|--------|-------|---------------|
| Launch Page | `/launch` | No |
| Terms | `/terms` | No |
| Privacy | `/privacy` | No |
| Health Check | `/up` | No |

---

## Design

- **Figma:** https://www.figma.com/design/Vi7qdepuk2lWGl4TWXbedb/SEASON.Vision-App-2026--Copy-
- **Primary colour:** `#933a35`
- **Secondary:** `#6B6B6B`
- **Background:** `#FAF7F4`
- **Field background:** `#F5EDE8`
- **Error background:** `#FDF0EE`
- **Font:** Montserrat (loaded via layout)
- **Mobile base:** 390px, max-w-md container

---

## Deployment

- **Platform:** Render
- **Database:** Render PostgreSQL
- **Build command:** `bin/render-build.sh` (bundle install -> assets:precompile -> db:prepare)
- **Auto-deploy:** on push to `main`
- **Production cable adapter:** Solid Cable

### Build Script

`bin/render-build.sh`:
```bash
bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:prepare
```

---

## Development Notes

- `CLAUDE.md` contains full AI agent instructions -- read before making changes
- All user-facing strings must use `t()` i18n helpers -- never hardcode English
- Figma is the source of truth for all colours, spacing, and copy
- Brand primary is `#933a35` -- no substitutions
- `CycleCalculatorService` is the single source of truth for all cycle calculations
- `Authentication` concern is included once in `ApplicationController` -- do not re-include in subclasses

---

## 🛠 Database Engineering Standards

We follow high-integrity migration patterns to ensure 100% uptime and data safety for our users.
Reference: [Rails Migrations Best Practices](https://www.visuality.pl/posts/rails-migrations-best-practices)

### Core Rules

1. **Reversibility:** Every migration must be reversible (`change` or `up/down`).
2. **Schema Integrity:** Use null constraints and appropriate defaults at the DB level, not just in Rails models.
3. **No Downtime:** Avoid destructive actions (like removing columns) without a two-step deployment.
4. **Data vs Schema:** Keep data manipulation in Rake tasks, not migrations.

---

## Known Issues (pre-deploy)

| # | Severity | Issue | File |
|---|----------|-------|------|
| 1 | CRITICAL | `SettingsController` authentication commented out -- settings routes publicly accessible | `settings_controller.rb:4` |
| 2 | CRITICAL | PWA manifest has `name: "MasterTemplate"` and `theme_color: "red"` | `pwa/manifest.json.erb` |
| 3 | CRITICAL | `OmniauthController` calls `User.find_or_create_from_oauth` but User model only defines `User.from_omniauth` -- OAuth login crashes | `omniauth_controller.rb:40` |
| 4 | MEDIUM | `theme-color` meta tag is `#8E3E36` not `#933a35` | `layouts/application.html.erb:14` |
| 5 | MEDIUM | Burger menu text labels hardcoded English -- not using `t()` helpers | `layouts/_burger_menu.html.erb` |
| 6 | MEDIUM | Duplicate columns on users table: `locale`+`language`, `birthday`+`age`, `last_period_start`+`last_menstruation`, `cycle_length`+`cycle_days` | `db/schema.rb` |
| 7 | MEDIUM | `update_streak!` duplicated in `SymptomsController` and `SuperpowersController` | Both controllers |
| 8 | MEDIUM | `user_signed_in?` (Devise helper) mixed with `authenticated?` (custom) in layout | `layouts/application.html.erb:20` |
