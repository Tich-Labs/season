# Season App — Stakeholder Report
**Original Date:** 15 April 2026  
**Last Updated:** 6 May 2026  
**Prepared by:** Engineering  
**Audience:** Product, Founders, Investors

---

## Executive Summary

Season V2 is **launch ready**. Milestones M1–M5 and M7 are complete (283 screens built and Figma-aligned). All HIGH priority pre-launch items are resolved. One medium-priority item remains (Apple OAuth). The app is deployed on Render and accepting waitlist signups.

---

## Current Status — May 2026

| Area | Status |
|---|---|
| Milestones complete | M1, M2, M3, M4, M5, M7 ✅ |
| Milestones out of scope | M6 (Gamification) ❌ |
| Total screens built | 283 (all Figma-aligned) |
| Test suite | 76/76 passing ✅ |
| Security scan (Brakeman) | 0 warnings ✅ |
| Deployment | Live on Render ✅ |
| Email delivery | Resend configured ✅ |
| OAuth — Google & Facebook | ✅ Credentials set |
| OAuth — Apple | ⏳ Pending credentials |

---

## Milestone History

| Milestone | Description | Screens | Status | Completed |
|---|---|---|---|---|
| M1 | Signing In & Onboarding | 43 | ✅ Complete | 15 Apr 2026 |
| M2 | Calendar & Basic Cycle Display | 32 | ✅ Complete | ~17 Apr 2026 |
| M3 | Tracking / Learn | 64 | ✅ Complete | ~17 Apr 2026 |
| M4 | Forecasting & Appointments | 60 | ✅ Complete | ~28 Apr 2026 |
| M5 | Birth Control & Reminders | 60 | ✅ Complete | ~28 Apr 2026 |
| M6 | Gamification & Scoring Flames | 24 | ❌ Not in scope | — |
| M7 | Onboarding & Feedback | 17 | ✅ Complete | ~28 Apr 2026 |

---

## What Was Delivered (M1–M7)

### Product Screens
| Area | Status |
|---|---|
| Auth: signup, login, password reset | ✅ |
| 11-step onboarding (Figma pixel-perfect) | ✅ |
| Calendar: monthly, weekly, appointments | ✅ |
| Daily tracking: symptoms, superpowers, period | ✅ |
| Tracking / Learn: phase education, self analysis, streaks | ✅ |
| Forecasting & appointment management | ✅ |
| Birth control & reminder management | ✅ |
| Settings: profile, calendar, notifications, subscriptions | ✅ |
| Invite flow for migrating users | ✅ |
| Launch countdown page + waitlist signup | ✅ |
| Legal: Terms + Privacy | ✅ |

**29 controllers · 12 models · 53+ views · All routes implemented**

### Admin Panel
| Feature | Status |
|---|---|
| User list with search, filters, CSV export | ✅ Live |
| User detail (cycle data, activity, streak) | ✅ Live |
| Inbox: feedback, bugs, support with CSV export | ✅ Live |
| Launch signups list with count badge + CSV export | ✅ Live |

### Infrastructure & Security
| Check | Result |
|---|---|
| Security scan (Brakeman) | ✅ 0 warnings |
| ERB lint | ✅ 0 errors |
| Automated tests | ✅ 76/76 passing |
| PostgreSQL-only stack | ✅ Confirmed |
| Email delivery (Resend) | ✅ Configured |
| Rate limiting (Rack::Attack) | ✅ On login, password, launch-signup |
| DNS rebinding protection (config.hosts) | ✅ Set via ENV["APP_HOST"] |
| Rails 8.1 defaults | ✅ Updated |
| Devise paranoid mode | ✅ Enabled |

---

## Remaining Items

### High Priority
| Item | Owner | Status |
|---|---|---|
| Apple OAuth credentials | Product / Founders | ⏳ Awaiting credentials from Apple Developer account |

### Medium Priority (Post-Launch)
| Item | Notes |
|---|---|
| CSP enforcement | Flip `report_only` to `false` in production.rb |
| Active Storage → Cloudflare R2 | Switch before launch to avoid avatar loss on redeploy |
| Sentry DSN | Set `SENTRY_DSN` env var in Render dashboard |

### Technical Debt (Non-Blocking)
| Issue | Impact |
|---|---|
| Hardcoded English strings in onboarding | German users see English — M8 target |
| Burger menu text not using `t()` | German users see English nav |
| Duplicate columns on `users` table | Schema noise, no user impact |

---

## Deployment

- **Platform:** Render — auto-deploys on every push to `main`
- **URL:** `https://seasonv2.onrender.com`
- **Database:** Render PostgreSQL
- **Monitoring:** Sentry wired (DSN to be set)
- **Security:** `RAILS_MASTER_KEY` set manually on Render; `SECRET_KEY_BASE` auto-generated

---

*Last updated: 6 May 2026 — all M1–M5, M7 complete and deployed.*

