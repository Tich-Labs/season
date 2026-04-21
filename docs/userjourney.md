# Season — User Journey

This document traces the full experience of a Season user from the moment they land on the app to daily tracking. It is written as a narrative walkthrough, not a feature checklist. The goal is to give any new team member a clear mental model of what the app does and why it is designed the way it is.

For screen-by-screen route and Figma references, see [screenslist.md](screenslist.md).

---

## Phase 0 — Before the App: The Waitlist

Before Season V2 was live, the landing page at `/launch` collected email addresses from people interested in the app. The page shows a countdown timer to the launch date and a single email input. This is the only pre-auth surface in the app.

**Why it exists:** Season has 150 existing V1 users who need to migrate their data and set up proper accounts. The waitlist captures intent and gives the team a contact list for the launch day notification email.

**What happens to signups:** Emails are stored in the `launch_signups` table and are visible in the admin panel at `/admin/launch_signups`. A launch notification mailer (`LaunchSignupMailer`) is built and ready — it is waiting on SMTP configuration before it can send.

---

## Phase 1 — First Contact: Sign Up

A new user arrives at `/welcome`. They see the Season brand, a brief value proposition, and two choices: create an account or sign in.

### Signing Up (`/registration/new`)

The sign-up form asks for name, email, and password. It also supports social login via Google, Facebook, or Apple — these are built and routed, pending OAuth credentials being added to the production environment.

Errors are shown inline via Turbo Streams — there is no page reload on failure. A wrong email format or a duplicate account shows a styled error message inside the form, not a separate error page.

On success, Devise creates the account and sends a confirmation email (once SMTP is configured). The user is redirected into the onboarding flow.

### Existing Users — The Invite Flow (`/invite/:token`)

The 150 existing V1 users receive a personalised invite link. When they land on `/invite/:token`, the app pre-fills their name and email based on the invite record. They set a password and their existing cycle data is migrated to the new account. This is the zero-friction migration path for the founding user base.

---

## Phase 2 — Onboarding (11 Steps)

Onboarding is a Hotwire-driven multi-step form at `/onboarding/:id`. It collects everything the app needs to personalise the experience before the user sees their first calendar. There are no skippable steps that break the core experience — only genuinely optional ones (cycle length estimation, period start date, reminder preferences).

**What each step collects and why:**

| Step | What | Why it matters |
| --- | --- | --- |
| 1 | Name | Personalises all greetings and prompts throughout the app |
| 2 | Birthday | Age-relevant cycle context; used for future health insights |
| 3 | "Do you have a regular cycle?" | Forks the onboarding — irregular cycles get a different setup path |
| 4 | Average cycle length (skippable) | Seeds `CycleCalculatorService` with accurate phase boundaries. Default is 28 days if skipped |
| 5 | "Do you use hormonal birth control?" | Hormonal contraception changes the cycle pattern; the app adapts its insights accordingly |
| 6 | Contraception method | Determines which birth control reminder to offer |
| 7 | "Want a birth control reminder?" | Opt-in; creates a `Reminder` record if yes |
| 8 | Contraception type (full list) | Captures the complete contraception picture |
| 9 | Food preference | Seeds nutrition tips — vegetarian, vegan, pescetarian options |
| 10 | Last period start date (skippable) | The single most important data point — seeds the cycle engine. The app works without it but all phase calculations are approximate |
| 11 | "Want cycle stage reminders?" | Opt-in push/email reminders 2 days before each phase change |

At the end of onboarding, the user arrives at the **Finish screen** (`/onboarding/finish`) — an animated confirmation screen with three progress dots and a "Start my Journey" button. This is the emotional handoff from setup to app.

---

## Phase 3 — The Calendar (Daily Use, Entry Point)

After onboarding, every session starts on the Calendar. This is the home screen.

### Monthly View (`/calendar`)

The monthly calendar is colour-coded by cycle phase. Days are shaded in the phase colour for that date based on the user's cycle data. The user's name and the current month appear in the header.

At the top of the page is a **phase banner** showing the user's current season (e.g., "You're in Summer — Ovulation phase") with the cycle day count. This is the first personalised insight the user sees every time they open the app.

Tapping any date navigates to the Daily View for that date. Tapping the "+" FAB creates a new calendar event.

### Weekly View (`/calendar/weekly`)

A horizontal week strip showing the same phase colours at a glance. Used for quick navigation when the user wants to see the coming days rather than the whole month.

### Appointments (`/calendar/appointments`)

A list view of all upcoming calendar events the user has created. Each event shows title, date, time, and category. Events can be edited inline.

### Daily View (`/daily/:date`)

The richest single screen in the app. For a given date it shows:
- The cycle phase and season for that day
- Symptom log summary (if logged)
- Superpower for that phase
- Nutrition and sport tips personalised to the phase
- Any calendar events for that day

This is the "what does my body need today?" screen.

---

## Phase 4 — Tracking (The Core Loop)

Tracking is what brings users back daily. There are three distinct tracking surfaces:

### Period Entry (`/tracking/period`)

A full-screen monthly calendar picker where the user taps a date to record the start of her period. The app saves a `CycleEntry` record and recalculates all future phase predictions from that anchor point.

The screen is context-aware: if a period start date already exists it shows "Edit period start" mode; if not it shows "Enter period start" mode. One screen, two states.

### Symptom Logging (`/symptoms`)

The symptom log is an accordion form organised into three sections: **Mood**, **Physical**, and **Mental**. Each section contains rated fields (1–5 scale). The full set of trackable fields:

**Mood:** mood, energy  
**Physical:** sleep, pain, cravings, discharge, temperature (°C), weight (kg), sexual intercourse  
**Mental:** mental state, physical state  

There is also a free-text **Notes** field for anything that doesn't fit a category, plus optional temperature and weight inputs.

All fields auto-save via Stimulus — there is no submit button. The user taps a value, it saves silently to the server via a Turbo Stream PATCH, and the UI confirms with a subtle indicator. The experience is designed to feel like ticking off a checklist, not filling in a form.

### Superpowers (`/superpowers`)

Each cycle phase has a "superpower" — a specific area where the user tends to excel. Summer (Ovulation) is communication and confidence. Winter (Menstrual) is intuition and reflection. The Superpowers screen lists these with explanations. The user can log when they experience a superpower to build a personal record over time.

### Streaks (`/streaks`)

A streak is the number of consecutive days the user has opened the app and logged something. The Streaks screen shows the current streak, best streak, and milestone markers. It is a lightweight gamification hook — not the main draw of the app, but a reason to keep daily tracking habits alive.

---

## Phase 5 — Learn (Phase Education)

At `/informations`, the user can explore each of the four cycle phases in depth. Each phase has its own detail page (`/informations/:phase`) covering:

- What is happening biologically
- How energy typically feels
- What to eat and how to exercise
- Emotional patterns common to this phase
- How to use the phase intentionally

This is not a blog or content feed — it is a reference guide tied directly to what the user is experiencing right now. The content is seeded per phase and locale (en/de) in the `CyclePhaseContent` model.

---

## Phase 6 — Settings (Personalisation and Account)

Settings are split into four sections, each with its own screen:

**Profile (`/settings/profile`):** Name, email, birthday, avatar upload. Email change triggers a confirmation email.

**Calendar (`/settings/calendar`):** Calendar display preferences — which day the week starts on, whether to show phase colours.

**Notifications (`/settings/notifications`):** Granular toggle control over which reminders the user receives — morning check-in, period start warning, birth control reminder. Each toggle is saved immediately via a PATCH request.

**Subscriptions (`/settings/subscriptions`):** Current plan and upgrade options. Stripe is wired but not yet active; the screen is present and designed but shows a free tier for now.

---

## Phase 7 — Feedback and Support

A persistent **feedback button** is available throughout the main app via the burger menu. Tapping it opens a bottom sheet modal (the `_feedback_modal` partial) with three tabs: Feedback, Bug Report, and Support.

The user writes a message, optionally attaches a screenshot, and submits. The message is saved as a `Feedback` record and forwarded automatically to the team's Trello board via `TrelloMailer`. The admin inbox at `/admin/inbox` shows all submissions organised by type with CSV export.

---

## Edge Cases and Error States

**No cycle data:** A user who skips the period start date during onboarding still gets a working calendar — phase colours show a placeholder state and the phase banner says "Set up your cycle" with a link to the period entry screen.

**New device / session expiry:** Sessions expire after 7 days. On expiry the user is redirected to `/session/new` with a soft message. No data is lost.

**Password recovery:** The standard Devise flow. The user enters their email at `/users/password/new`, receives a reset link (pending SMTP), and sets a new password. Three error states have dedicated screens: already reset, inbox full, wrong email.

**Invite link reuse:** An invite token can only be used once. A second attempt shows an "already used" message with a prompt to log in instead.

---

## What the Journey Feels Like (Design Intent)

The app is designed to feel like a personal health companion rather than a medical tracker. The seasonal metaphor is not decorative — it is the lens through which every insight is framed. The colour palette (warm reds, creams, muted pinks) reinforces that this is an intimate, personal space. The typography is clean and readable. There are no aggressive notifications, no streaks that guilt the user, no comparison to other users.

The core promise Season makes to its user: **understand your body on your own terms, and use that understanding to live better.**
