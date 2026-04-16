# Screens & Routes Mapping Table

This table maps coded screens to Figma design nodes. Use `designs/figma_nodes.md` as the source of truth.

## Milestone Reference
| Milestone | Figma Screens | Status |
|-----------|---------------|--------|
| M1 | 43 | ✅ Built |
| M2 | 32 | ✅ Built |
| M3 | 64 | 🔶 Partial (5/64) |
| M4 | 60 | ✅ Built |
| M5 | 60 | ✅ Built |
| M6 | 24 | ❌ Not built |
| M7 | 17 | ✅ Built |

## Styling Standard (Last updated: 2026-04-16)

**Approach**: Inline styles (not Tailwind) — easier to maintain globally.

**Shared Partial Conventions**:
- `_section_header` — Section titles (color:#933a35, font-size:16px, font-weight:700)
- `_settings_nav_row` — Settings list rows with icon + label + chevron
- `_toggle_switch` — Accessible toggle (44×24, role=switch, aria-checked)
- `_phase_banner` — Phase-coloured header band
- `_content_container` — Standard max-width:430px container
- `_layout_vars` — CSS variables placeholder

**Brand Colors**:
- Primary: #933a35
- Background: #FAF7F4
- Divider: #DDD0CB
- Field background: #EDE1D5
- Accent muted: #D18D83

**Shared Partial Library**:
| Partial | Purpose |
|---------|---------|
| `_section_header` | Section titles (16px, 700, #933a35) |
| `_settings_nav_row` | Settings list rows (icon + label + chevron) |
| `_settings_toggle_row` | Settings toggle rows |
| `_toggle_switch` | Accessible toggle (44×24, role=switch) |
| `_phase_banner` | Phase-coloured header band |
| `_content_container` | Standard max-width:430px container |
| `_layout_vars` | CSS variables placeholder |

## Route Mapping

| Route/Path                       | Controller#Action           | Purpose/Screen Name           | Figma Node (from designs/figma_nodes.md) | Status |
|----------------------------------|-----------------------------|-------------------------------|------------------------------------------|--------|
| /app                             | home#app                    | App landing                   | M1-1                                     | ✅ |
| /loader                          | home#loader                 | Loader/countdown              | M1-2                                     | ✅ |
| /welcome                         | home#welcome                | Splash/Welcome                | M1-3                                     | ✅ |
| /registration/new                | registrations#new           | Sign up                       | M1-4                                     | ✅ |
| /session/new                     | sessions#new                | Log in                        | M1-5                                     | ✅ |
| /users/password/new              | devise/passwords#new        | Password recovery             | M1-6                                     | ✅ |
| /users/password/edit             | devise/passwords#edit       | Password reset                | M1-7                                     | ✅ |
| /password/done                   | passwords#done              | Password done                 | M1-8                                     | ✅ |
| /password/error/already-reset    | passwords#error_already_reset| Password error: already reset | M1-9                                   | ✅ |
| /password/error/inbox-full       | passwords#error_inbox_full  | Password error: inbox full    | M1-10                                    | ✅ |
| /password/error/wrong-email      | passwords#error_wrong_email | Password error: wrong email   | M1-11                                    | ✅ |
| /password/error/contact          | passwords#error_contact     | Password error: contact      | M1-12                                    | ✅ |
| /invite/:token                   | invites#show                | Invite landing                | M1-13                                    | ✅ |
| /onboarding/:id                  | onboarding#show             | Onboarding steps 1-11         | M1-14 to M1-24                           | ✅ |
| /onboarding/finish               | onboarding#finish           | Onboarding finish             | M1-25                                    | ✅ |
| /calendar                        | calendar#index              | Calendar monthly              | M2-1                                     | ✅ |
| /calendar/weekly                 | calendar#weekly             | Calendar weekly               | M2-2                                     | ✅ |
| /calendar/appointments           | calendar#appointments       | Calendar appointments         | M2-3                                     | ✅ |
| /calendar_events/new             | calendar_events#new         | Calendar event add            | M2-4                                     | ✅ |
| /calendar_events/:id/edit        | calendar_events#edit        | Calendar event edit           | M2-5                                     | ✅ |
| /daily/:date                     | daily_view#show             | Daily view                    | M2-6                                     | ✅ |
| /tracking                        | tracking#index              | Tracking/period entry         | M2-7                                     | ✅ |
| /symptoms                        | symptoms#index              | Symptoms list                 | M2-8                                     | ✅ |
| /symptoms/:id                    | symptoms#show               | Symptoms detail               | M2-9                                     | ✅ |
| /superpowers                     | superpowers#index           | Superpowers list              | M2-10                                    | ✅ |
| /superpowers/:id                 | superpowers#show            | Superpowers detail            | M2-11                                    | ✅ |
| /streaks                         | streaks#index               | Streaks                       | M2-12                                    | ✅ |
| /settings/edit                   | settings#edit               | Settings main                 | M4-1                                     | ✅ |
| /settings/profile                | settings#profile            | Settings profile              | M4-2                                     | ✅ |
| /settings/subscriptions          | settings#subscriptions      | Settings subscriptions        | M4-3                                     | ✅ |
| /settings/calendar               | settings#calendar           | Settings calendar             | M4-4                                     | ✅ |
| /settings/notifications          | settings#notifications      | Settings notifications        | M4-5                                     | ✅ |
| /settings/notification_morning   | settings#notification_morning | Morning notification        | M5-1                                     | ✅ |
| /settings/notification_period   | settings#notification_period | Period notification          | M5-2                                     | ✅ |
| /settings/notification_birth_control | settings#notification_birth_control | Birth control notification | M5-3                                     | ✅ |
| /launch                          | launch#index                | Launch/countdown              | M1-26                                    | ✅ |
| /terms                           | legal#terms                 | Terms                         | M1-27                                    | ✅ |
| /privacy                         | legal#privacy               | Privacy                       | M1-28                                    | ✅ |
| /informations                    | informations#index          | Informations main             | M3-1                                     | 🔶 Partial |
| /informations/:phase             | informations#show           | Informations phase detail     | M3-2 to M3-5                             | 🔶 Partial |
| /admin                           | admin/users#index           | Admin users list              | M7-1                                     | ✅ |
| /admin/users/:id                 | admin/users#show            | Admin user detail             | M7-2                                     | ✅ |
| /admin/inbox                     | admin/inbox#overview        | Admin inbox (all messages)    | M7-3                                     | ✅ |
| /admin/inbox/feedback            | admin/inbox#feedback        | Admin feedback                | M7-4                                     | ✅ |
| /admin/inbox/bugs                | admin/inbox#bugs            | Admin bugs                    | M7-5                                     | ✅ |
| /admin/inbox/support             | admin/inbox#support         | Admin support                 | M7-6                                     | ✅ |
| /admin/launch_signups            | admin/launch_signups#index  | Admin waitlist                | M7-7                                     | ✅ |
| /admin/launch_signups/export_csv | admin/launch_signups#export_csv | Admin waitlist CSV        | M7-8                                     | ✅ |
| /admin/inbox/export_csv          | admin/inbox#export_csv      | Admin inbox CSV               | M7-9                                     | ✅ |

## Known Gaps

### M3: Tracking / Learn (64 screens)
**Built**: 5 screens (informations index + 4 phase detail pages)
**Missing**: 59 screens from Figma nodes 12068-* covering:
- Educational articles
- Tips & guidance content
- Community features
- Phase-specific learning modules

### M6: Gamification & Scoring Flames (24 screens)
**Status**: Not built (not in scope)

## How to use this table
1. Cross-reference routes with Figma nodes in `designs/figma_nodes.md`
2. For visual comparison, compare actual app screens against Figma designs
3. Update status column as screens are verified