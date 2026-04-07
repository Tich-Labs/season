# Season — Menstrual Cycle Tracking App

A Rails 8 PWA for tracking menstrual cycles, symptoms, and productivity based on cycle phases.

## Tech Stack

- **Ruby**: 3.4.7
- **Rails**: 8.0.5
- **Database**: PostgreSQL
- **CSS**: Tailwind CSS v4
- **Auth**: Custom cookie-based + Devise (password recovery)
- **PWA**: Manifest + Service Worker

## Brand Colours

| Name | Hex | Usage |
|------|-----|-------|
| Primary | `#933a35` | Buttons, headings |
| Secondary | `#6B6B6B` | Body text |
| Background | `#FAF7F4` | Page backgrounds |
| Field BG | `#F5EDE8` | Form inputs |
| Error BG | `#FDF0EE` | Error containers |

## Screen Flow

```
/ (root) → loader.html.erb → (2s) → /welcome → signup OR login → calendar
```

| Route | View | Status |
|-------|------|--------|
| `/` | `home/loader.html.erb` | ✅ Screen 1: logo + "SEASON" |
| `/loader` | `home/loader.html.erb` | ✅ Same as root |
| `/welcome` | `home/welcome.html.erb` | ✅ "Let's go" / "I already have an account" |
| `/registration/new` | `registrations/new.html.erb` | ✅ Sign up |
| `/session/new` | `sessions/new.html.erb` | ✅ Log in |
| `/onboarding/:id` | `onboarding/show.html.erb` | ✅ 5-step flow |
| `/calendar` | `calendar/index.html.erb` | ✅ Main app |
| `/daily/:date` | `daily_view/show.html.erb` | ✅ Day detail |
| `/tracking` | `tracking/index.html.erb` | ✅ Period log |
| `/symptoms` | `symptoms/index.html.erb` | ✅ Symptom log |
| `/superpowers` | `superpowers/index.html.erb` | ✅ Fixed |
| `/streaks` | `streaks/index.html.erb` | ✅ Streaks |
| `/settings/edit` | `settings/edit.html.erb` | ⚠️ Save broken |

## Routes

### Auth Flow (no bottom nav)

| Path | Controller#Action | Status |
|------|-------------------|--------|
| `/` | home#loader | ✅ |
| `/welcome` | home#welcome | ✅ |
| `/registration/new` | registrations#new | ✅ |
| `/registration` | registrations#create | ✅ |
| `/session/new` | sessions#new | ✅ |
| `/session` | sessions#create | ✅ |
| `/session` | sessions#destroy | ✅ |

### Main App (with bottom nav)

| Path | Controller#Action | Status |
|------|-------------------|--------|
| `/calendar` | calendar#index | ✅ |
| `/calendar_events/new` | calendar_events#new | ✅ |
| `/calendar_events` | calendar_events#create | ✅ |
| `/daily/:date` | daily_view#show | ✅ |
| `/tracking` | tracking#index | ✅ |
| `/tracking` | tracking#create | ✅ |
| `/symptoms` | symptoms#index | ✅ |
| `/symptoms` | symptoms#create | ✅ |
| `/superpowers` | superpowers#index | ✅ |
| `/superpowers` | superpowers#create | ✅ |
| `/streaks` | streaks#index | ✅ |
| `/settings/edit` | settings#edit | ✅ |

## CycleCalculatorService

Located at `app/services/cycle_calculator_service.rb`.

```ruby
SEASON_NAMES = {
  "menstrual" => "Winter",
  "follicular" => "Spring",
  "ovulation" => "Summer",
  "luteal" => "Autumn"
}
```

Key methods: `current_phase`, `phase_for_date(date)`, `month_data(year, month)`, `colour_for_date(date)`

## Known Issues

| # | Issue | File |
|---|-------|------|
| C4 | Settings save redirects to undefined route | `settings_controller.rb` |

## Auth Suspended (dev mode)

Currently disabled in `ApplicationController` for preview. Re-enable:

```ruby
# app/controllers/application_controller.rb
include Authentication
```

## Getting Started

```bash
rbenv install 3.4.7
bundle install
RBENV_VERSION=3.4.7 bundle exec rails db:create db:schema:load
cp .env.template .env
bin/dev
```