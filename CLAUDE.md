# AGENT INSTRUCTIONS — READ BEFORE DOING ANYTHING
# This file applies to ALL AI agents: Claude Code, OpenCode, Cursor, Copilot
# Follow every instruction in this file exactly.

# 1. Install
npm install -g @anthropic-ai/claude-code
npx skills add julianrubisch/skills

# 2. Create the app
rails new season --database=postgresql \
  --css=tailwind --skip-docker \
  --skip-kamal --skip-jbuilder

# 3. Drop CLAUDE.md in root
cp CLAUDE.md ./season/CLAUDE.md

# 4. Start Claude Code
cd season
claude

# 5. First prompt:
"Read CLAUDE.md then use jr-rails-new to scaffold Season.
 ERB views, Rails built-in auth, Solid Queue, AASM, Pundit,
 Tailwind mobile-first. Skip Docker, Kamal, Thruster.
 Add PWA manifest and service worker before any views.
 Wire i18n en/de before generating any ERB."

## Brand Colours

Primary: **#933a35** (from Figma — not #7D3030)
Secondary: #6B6B6B
Background: #FAF7F4
White: #FFFFFF
Field background: #F5EDE8
Error background: #FDF0EE

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

### Error states
- Log in error
- Sign up error
- General 404
- General 500

## Asset naming conventions

All image and asset files placed in `app/assets/images/` must follow these rules:

- **Lowercase only** — no uppercase letters
- **Hyphens instead of spaces** — `season-logo.svg` not `season logo.svg`
- **No special characters** — no parentheses, dots (except extension), or punctuation
- **Descriptive, short names** — `errorscreen-wrong-email.png` not `Errorscreen - wrong email.png`

Examples:
- `Season-Wortmarke-1.svg` ✅ (was `Season-Wortmarke 1.svg` ❌)
- `Apple-Logo.png` ✅ (was `Apple Logo.png` ❌)
- `errorscreen-wrong-email.png` ✅ (was `Errorscreen - wrong email.png` ❌)

**Why**: Propshaft fails to digest and serve asset filenames containing spaces during production `assets:precompile` on Render, causing 404s in production.

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