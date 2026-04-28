# Season — Project Overview

**Read this first. Everything else in this docs folder assumes you've read this.**

---

## What is Season?

Season is a women's menstrual cycle tracking app built for a community of users who want to understand their body through a seasonal lens rather than a clinical one. Where most cycle apps reduce a woman's experience to a countdown to her next period, Season maps the full cycle to four seasons — Winter, Spring, Summer, Autumn — and uses that framework to surface personalized insights about energy, mood, nutrition, and strength at each phase.

The app is a **progressive web app (PWA)** built on Ruby on Rails 8, designed to feel like a native iOS app on mobile. It runs in the browser at full fidelity and is on a roadmap to ship as a Hotwire Native wrapper on the App Store.

---

## The Core Idea

A woman's menstrual cycle has four phases. Season maps them like this:

| Phase | Season | Approximate Days | What it means |
|-------|--------|-----------------|---------------|
| Menstrual | Winter | Days 1–5 | Rest, reflection, inward energy |
| Follicular | Spring | Days 6–13 | Rising energy, creativity, new starts |
| Ovulation | Summer | Days 14–17 | Peak energy, sociability, confidence |
| Luteal | Autumn | Days 18–28 | Slowdown, nesting, preparation |

Every screen in the app is phase-aware. The calendar is colour-coded by phase. Tracking prompts adapt to where the user is in her cycle. Superpower insights tell her what she's likely to excel at this week. The entire experience is built around the idea that understanding your cycle is a competitive advantage, not just a health necessity.

---

## Who is the User?

Season was originally built for **150 existing users** migrating from a first version (V1) of the app. These are women who were already tracking their cycle and understand the seasonal metaphor. V2 is a ground-up rebuild with proper backend persistence, a full settings system, and a launch funnel for new user growth.

The app supports **English and German** (DE translations complete). The current user base is primarily German-speaking European women, with a global expansion roadmap.

---

## What Has Been Built

Season V2 is **feature-complete for launch**. Every screen across seven milestones has been designed in Figma and built in code:

| Milestone | What it covers | Status |
|-----------|---------------|--------|
| M1 — Foundation | Auth, onboarding, all base screens | ✅ Complete |
| M2 — Calendar & Cycle Display | Monthly/weekly calendar, appointments, daily view | ✅ Complete |
| M3 — Tracking & Learn | Symptom logging, period entry, phase education, superpowers, streaks | ✅ Complete |
| M4 — Forecasting & Appointments | Cycle predictions, appointment management | ✅ Complete |
| M5 — Birth Control & Reminders | Contraception tracking, cycle phase reminders | ✅ Complete |
| M6 — Gamification | Streak flames and reward badges | ❌ Not in scope for launch |
| M7 — Feedback & Admin | In-app feedback, admin panel, waitlist | ✅ Complete |

The app is deployed on Render, auto-deploys on every push to `main`, and is connected to a live PostgreSQL database.

---

## What is Still Needed Before Launch

One thing is blocking launch:

**OAuth credentials** — Sign in with Google, Facebook, and Apple is fully built and routed. The only step remaining is adding the API keys to the Render dashboard. No code changes needed.

Everything else — accessibility, i18n completeness, schema cleanup — is improvement work that can happen post-launch.

> **Resolved 26 April 2026 — Email delivery:** Resend is configured and the `season.vision` domain is fully verified (SPF, DKIM, MX on Squarespace). Password reset and account confirmation emails now deliver to inbox with custom branded HTML templates. End-to-end password reset confirmed working in production.
>
> **Completed 26 April 2026 — M5 Reminders:** `ReminderMailer` built with three actions: `morning_summary` (daily phase/superpower/tip), `period_reminder` (period start or end with predicted date), and `birth_control_reminder` (daily pill reminder). Three Solid Queue jobs (`SendMorningRemindersJob`, `SendPeriodRemindersJob`, `SendBirthControlRemindersJob`) run on a production cron schedule (07:00, 08:00, 19:00 UTC). All three notification settings screens now persist to the database via `PATCH /settings/save_morning_reminder`, `PATCH /settings/save_period_reminder`, and `PATCH /settings/save_birth_control_reminder`. Migration adds `advance_days` column to the `reminders` table.
>
> **Completed 28 April 2026 — GDPR consent system:** `UserConsent` model and audit trail table added. `ConsentCheck` concern enforces health-data consent before any tracking screen is accessible. `/settings/consent` lets users grant or revoke consent at any time. `AccountController` added for GDPR Art. 17 account deletion.
>
> **Completed 28 April 2026 — Security hardening:** `force_ssl = true`, CSP fully enforced (not report-only), `permissions_policy.rb` created, host authorization enabled, all debug/test routes moved behind `unless Rails.env.production?` guard.
>
> **Completed 28 April 2026 — Admin CMS CRUD:** `Admin::CyclePhaseContentsController` now has full create/edit/delete, giving the team control over `/informations/:phase` content without Rails console access.
>
> **Completed 28 April 2026 — Informations show redesign:** Phase detail pages rebuilt to match Figma — flat white layout, phase-coloured text throughout, three sections (phase title + hormone note, emotional world, that will do you good) separated by divider lines.

---

## The Technology

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Rails 8.1 | Full-stack, convention-over-configuration, Hotwire native |
| Frontend | Hotwire (Turbo + Stimulus) | Single-page app feel, no separate JS framework |
| CSS | Tailwind CSS | Utility-first, design system via brand tokens |
| Database | PostgreSQL | Production-grade, no SQLite anywhere |
| Auth | Devise (passwords) + custom cookie sessions | Simplest correct approach |
| Background jobs | Solid Queue | Rails-native, no Redis dependency |
| Deployment | Render | Auto-deploy from GitHub, managed PostgreSQL |
| Error tracking | Sentry | Production error visibility |

The app is deliberately **dependency-light**. No React, no GraphQL, no separate API layer. Rails renders HTML, Turbo makes it fast, Stimulus handles interactions. The architecture is intentionally easy to hand off.

---

## Codebase at a Glance

```
app/
  controllers/     — 32 controllers (auth, features, admin, consent, account)
  models/          — 13 models (User, CycleEntry, SymptomLog, UserConsent, etc.)
  views/           — ~65 ERB templates, Figma-matched
  javascript/
    controllers/   — Stimulus controllers (menu, modal, symptoms, calendar, etc.)
  services/
    cycle_calculator_service.rb   — Single source of truth for phase/day calculations
  jobs/            — SendMorningRemindersJob, SendBirthControlRemindersJob, SendPeriodRemindersJob

config/
  locales/en.yml   — All English strings
  locales/de.yml   — All German translations

db/
  schema.rb        — Full database schema
  migrate/         — All migrations (reversible)

docs/              — You are here
```

---

## Key Design Decisions

**The cycle engine lives in one place.** `CycleCalculatorService` is the single source of truth for which phase a user is in, what day of her cycle it is, and what colour the calendar should show. Nothing else calculates phases. If the logic ever needs to change, there is one file to change.

**Health data never touches the logs.** All symptom fields, cycle data, and health profile fields are filtered from Rails request logs. A user's weight, mood score, period start date, and contraception type will never appear in plain text in any log file. See [userdata.md](userdata.md) for the full privacy architecture.

**Figma is the source of truth for every pixel.** Every screen was built from a Figma node. Brand colours, spacing, typography, and copy all come from Figma first, then get translated to Tailwind. The Figma file is the design contract, not a mood board.

**The admin panel is built for the founding team, not a SaaS admin.** It covers exactly what the Season team needs: a user list with search, a feedback inbox (bugs / support / feedback), and waitlist tracking with CSV export. Nothing more. Admin auth is completely separate from the mobile app login — `/admin/login` uses its own `admin_auth` layout (desktop-optimised, no sidebar) handled by `Admin::SessionsController`. Unauthenticated requests to `/admin/*` redirect to `/admin/login`, not the app root. Test accounts and admin promotion are provisioned via `bundle exec rails setup:accounts` — no Rails console needed.

---

## How to Read the Rest of These Docs

| Document | Read it when... |
|----------|----------------|
| [User Journey](userjourney.md) | You want to understand what a user actually experiences, screen by screen |
| [Screens & Routes](screenslist.md) | You're building or debugging a specific screen and need the route, controller, and Figma node |
| [Backlog](BACKLOG.md) | You're picking up a task or need to understand what's left to build |
| [User Data & Privacy](userdata.md) | You're touching anything that handles personal or health data |
| [Stakeholder Report](STAKEHOLDER-REPORT-2026-04-15.md) | You need a non-technical summary of what's built and what's next |
| [Audit Report](AUDIT-2026-04-10.md) | You want a full technical audit: accessibility, security, lint, test results |
| [Styling Audit](STYLING-AUDIT.md) | You're writing CSS or Tailwind classes and need to know the standards |
| [Figma Nodes](figma_nodes.md) | You're mapping a screen to its Figma design source |
