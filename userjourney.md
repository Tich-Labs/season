# User Journey & Product Review

This document reviews the Season app’s current user experience and product flows from a Product Manager’s perspective, highlighting what matters for stakeholders and users.

---

## 1. First Impressions & Onboarding
- **Landing/Welcome:** Branded, Figma-aligned, clear value proposition.
- **Sign Up / Log In:** Simple forms, inline error handling, i18n-ready.
- **Onboarding:** 11-step guided flow (name, birthday, cycle, preferences, etc.), visually polished, accessible, with Turbo Stream validation. 
- **Friction:** Minimal; all steps are single-action, with skip/unsure options where needed.
- **Differentiator:** Cycle science and personalization start at onboarding.

## 2. Core App Flows
- **Calendar:** Monthly/weekly views, color-coded by cycle phase, with event/appointment creation and editing. 
- **Tracking:** Daily symptom and period tracking, streaks, and superpowers.
- **Insights:** Forecast and analytics screens, cycle predictions, and personalized tips.
- **Settings:** Profile, subscriptions, notifications, calendar integration.
- **Legal:** Terms and privacy, with clear contact (info@season.vision).

## 3. Error Handling & Accessibility
- **Inline errors:** All forms use Turbo Streams for instant feedback, styled per brand.
- **Accessibility:** Most modals, forms, and navigation are ARIA-labeled and keyboard-accessible; some WCAG issues remain (see M2).
- **i18n:** All user-facing strings use translation helpers; German/English supported.

## 4. Admin & Backoffice
- **Admin panel:** User management, inbox (feedback/bugs/support), waitlist, CSV export.
- **Security:** Devise authentication, PostgreSQL-only, credentials managed securely.

## 5. Differentiators & Stakeholder Value
- **Brand alignment:** All screens match Figma, use exact color tokens, and Montserrat font.
- **Personalization:** Cycle phase, streaks, and insights are surfaced throughout.
- **Growth readiness:** Waitlist, invite flow, and launch tracking are built-in.
- **Reliability:** Automated tests, security/lint checks, and error monitoring (Sentry).

## 6. Friction Points & Next Steps
- **Email delivery:** SMTP not yet live (M2 priority).
- **OAuth:** Social login ready but needs credentials.
- **Accessibility:** 9 open issues (see M2 plan).
- **i18n:** Some onboarding strings still hardcoded.

---

## What Stakeholders Care About
- Is the onboarding smooth and conversion-optimized?
- Are all core flows (calendar, tracking, insights) live and visually polished?
- Is the app accessible, secure, and ready for App Store submission?
- Is the brand experience consistent and differentiated?
- Are admin and analytics tools in place for growth?

## What Users Care About
- Is it easy to get started and understand my cycle?
- Are insights and reminders personalized and actionable?
- Is the app visually appealing, fast, and error-free?
- Can I trust my data is secure and private?

---

This review is current as of 15 April 2026. For a full feature checklist, see the Stakeholder Report.
