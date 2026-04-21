# User Journey & Product Review

This document reviews the Season app’s current user experience and product flows from a Product Manager’s perspective, highlighting what matters for stakeholders and users.

---

## 1. First Impressions & Onboarding
- **Landing/Welcome:** Branded, Figma-aligned, clear value proposition.
- **Sign Up / Log In:** Simple forms, inline error handling, i18n-ready.
- **Onboarding:** 11-step guided flow (name, birthday, cycle, preferences, etc.), visually polished, accessible, with Turbo Stream validation. 
- **Friction:** Minimal; all steps are single-action, with skip/unsure options where needed.
- **Differentiator:** Cycle science and personalization start at onboarding.
- **WCAG:** Most onboarding steps accessible, but some ARIA and focus issues remain (see Accessibility below).

## 2. Core App Flows
- **Calendar:** Monthly/weekly views, color-coded by cycle phase, with event/appointment creation and editing. 
- **Tracking:** Daily symptom and period tracking, streaks, and superpowers. (M3: 5/64 tracking/learn screens built; 59 in progress)
- **Insights:** Forecast and analytics screens, cycle predictions, and personalized tips.
- **Settings:** Profile, subscriptions, notifications, calendar integration.
- **Legal:** Terms and privacy, with clear contact (info@season.vision).

## 3. Error Handling & Accessibility
- **Inline errors:** All forms use Turbo Streams for instant feedback, styled per brand. Auth errors are inline; onboarding uses flash redirects (to be improved).
- **Accessibility:** 11 of 20 WCAG 2.1 AA issues fixed. 9 remain (critical: cycle picker ARIA, settings toggles; major: error states, modal focus, avatar modal, Google button contrast; minor: alt text, auto-redirect). All new screens follow ARIA and keyboard guidelines.
- **i18n:** All user-facing strings use translation helpers; German/English supported. Some onboarding strings still hardcoded (M2 target).

## 4. Admin & Backoffice
- **Admin panel:** User management, inbox (feedback/bugs/support), waitlist, CSV export. Sidebar refactored for clarity and DRYness. Launch signups tracked with live badge and CSV export.
- **Security:** Devise authentication, PostgreSQL-only, credentials managed securely. Brakeman 0 warnings, ERB lint 0 errors, RuboCop clean (except known ERB parser false positives).

## 5. Differentiators & Stakeholder Value
- **Brand alignment:** All screens match Figma, use exact color tokens, and Montserrat font. Asset naming and error container styling per CLAUDE.md.
- **Personalization:** Cycle phase, streaks, and insights are surfaced throughout.
- **Growth readiness:** Waitlist, invite flow, and launch tracking are built-in.
- **Reliability:** Automated tests, security/lint checks, and error monitoring (Sentry). 76/76 tests passing. No SQLite in any environment.

## 6. Friction Points & Next Steps
- **Email delivery:** SMTP not yet live (M2 critical priority; provider decision needed, Resend recommended).
- **OAuth:** Social login ready but needs credentials added to Render dashboard.
- **Accessibility:** 9 open issues (see above; all targeted for M2 completion).
- **i18n:** Some onboarding strings still hardcoded (to be extracted in M2).
- **Tracking/Learn:** 59/64 M3 screens not yet built (in progress).
- **Rate limiting:** `/launch-signup` endpoint to be protected (M2 backlog).

---

## What Stakeholders Care About
- Is the onboarding smooth and conversion-optimized?
- Are all core flows (calendar, tracking, insights) live and visually polished?
- Is the app accessible, secure, and ready for App Store submission?
- Is the brand experience consistent and differentiated?
- Are admin and analytics tools in place for growth?
- Is email delivery and OAuth ready for launch?

## What Users Care About
- Is it easy to get started and understand my cycle?
- Are insights and reminders personalized and actionable?
- Is the app visually appealing, fast, and error-free?
- Can I trust my data is secure and private?
- Can I recover my password and sign in with Google/Apple?

---

This review is current as of 16 April 2026. For a full feature checklist and audit, see the Stakeholder Report.
