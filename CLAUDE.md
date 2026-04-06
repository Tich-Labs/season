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

### Auth flow (no bottom nav)
- App landing screen (before splash)
- Splash / welcome screen ✅ DONE
- Log in screen ✅ DONE (styled)
- Log in error state
- Sign up screen ✅ DONE (styled)
- Sign up error state
- Change password screen ✅ DONE (styled)
- Invite landing page (for 150 migrating users)
- Onboarding step 1 — name
- Onboarding step 2 — cycle length + period length
- Onboarding step 3 — contraception type
- Onboarding step 4 — last period start date
- Onboarding step 5 — language preference

### Main app (with bottom nav)
- Calendar — monthly view (M2)
- Calendar — event detail
- Calendar — add event form
- Daily tracking screen (M3)
- Symptoms screen (M3)
- Superpower screen (M3)
- Period entry screen (M3)
- Daily forecast / tips screen (M4)
- Appointments view (M4)
- Streaks screen (M6)
- Settings screen

### Error states
- Log in error
- Sign up error
- General 404
- General 500

## Error screen requirements

All error states must:
- Show inline errors NOT page-level redirects
- Use Turbo Stream to inject errors without full page reload
- Error text colour: **#933a35**
- Error container: `bg-[#FDF0EE] rounded-xl px-4 py-3 text-sm text-[#933a35]`
- Field with error: `border border-[#933a35]` on the input (add border class conditionally)
- Devise errors render via `devise/shared/error_messages` partial
- Custom error partial styling must match above