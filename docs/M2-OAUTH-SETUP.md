---
layout: default
---

# OAuth & Calendar Setup — Render Deployment

**Last updated:** 2026-09-19

---

## Overview

Season uses **Devise OmniAuth** for social login (Google, Facebook, Apple). Callback URLs follow the Devise pattern: `/users/auth/:provider/callback`.

Season also connects to three calendar providers under Settings → Calendar: **Google** (OAuth), **iCloud** (no OAuth), **Microsoft** (planned, not built).

All OAuth environment variables are already referenced in `config/initializers/devise.rb`. They need values set on Render.

---

## Environment Variables

| Variable | Provider | Source |
|----------|----------|--------|
| `GOOGLE_CLIENT_ID` | Google Cloud Console | OAuth 2.0 Client ID (Web) |
| `GOOGLE_CLIENT_SECRET` | Google Cloud Console | OAuth 2.0 Client Secret (Web) |
| `FACEBOOK_APP_ID` | Meta / Facebook App | App ID from dashboard |
| `FACEBOOK_APP_SECRET` | Meta / Facebook App | App Secret from dashboard |
| `APPLE_CLIENT_ID` | Apple Developer | Service ID (e.g. `com.seasonapp.web`) |
| `APPLE_TEAM_ID` | Apple Developer | Team ID from Membership page |
| `APPLE_KEY_ID` | Apple Developer | Key ID from Apple Developer Keys page |
| `APPLE_PRIVATE_KEY` | Apple Developer | Private key `.p8` file contents (with `\n` escaped) |

iCloud and Microsoft calendar sync need no environment variables (see their sections below).

---

## 1. Google OAuth (Google Cloud Console)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or use an existing one
3. **APIs & Services > Library** → enable **Google Calendar API**
4. **APIs & Services > OAuth consent screen** → add scope `https://www.googleapis.com/auth/calendar`
5. **APIs & Services > Credentials** → **Create Credentials > OAuth 2.0 Client ID** → **Web Application**
6. Under **Authorized redirect URIs**, add all four:
   - `https://seasonv2.onrender.com/users/auth/google_oauth2/callback` (login, prod)
   - `http://localhost:3000/users/auth/google_oauth2/callback` (login, dev)
   - `https://seasonv2.onrender.com/settings/google_calendar_callback` (calendar sync, prod)
   - `http://127.0.0.1:3000/settings/google_calendar_callback` (calendar sync, dev)
7. Copy **Client ID** → `GOOGLE_CLIENT_ID`
8. Copy **Client Secret** → `GOOGLE_CLIENT_SECRET`

**Login scope:** `email,profile` only — unrestricted, no Google verification required, works for any user.

**Calendar Sync scope:** `https://www.googleapis.com/auth/calendar`, requested only by the Settings → Calendar connect flow, separate from login.

### Google Calendar Sync routes

| Action | Route | Method | Description |
|--------|-------|--------|-------------|
| Connect | `/settings/connect_google_calendar` | GET | Builds OAuth URL, redirects to Google consent |
| Callback | `/settings/google_calendar_callback` | GET | Exchanges auth code for access/refresh tokens |
| Disconnect | `/settings/disconnect_google_calendar` | POST | Clears stored tokens |
| Sync | `/settings/sync_google_calendar` | POST | Imports Google Calendar events as `CalendarEvent` records |

Push (Season → Google) runs automatically in the background (`GoogleCalendarPushJob`) when a connected user creates, edits, or deletes an appointment.

**Env vars:**

```bash
GOOGLE_CLIENT_ID=your_client_id_here
GOOGLE_CLIENT_SECRET=your_client_secret_here
```

Same credentials serve both login and calendar sync — Google differentiates by callback URL.

**Error: `Missing required parameter: client_id`** → `GOOGLE_CLIENT_ID` is unset. Add it to `.env` and restart `bin/dev`.

---

## 2. iCloud Calendar Sync — no OAuth

Apple has no OAuth for calendar data. iCloud Calendar is accessed over **CalDAV**, authenticated with **HTTP Basic Auth** using an Apple ID email + an app-specific password.

**No console setup, no env vars.**

**User steps:**

1. [appleid.apple.com](https://appleid.apple.com) → **Sign-In and Security** → **App-Specific Passwords** → generate one
2. On Settings → Calendar, enter Apple ID email + the generated password
3. Season verifies the credentials immediately; a wrong password fails at this step, not on the first sync

### iCloud Calendar routes

| Action | Route | Method | Description |
|--------|-------|--------|-------------|
| Connect | `/settings/connect_icloud_calendar` | POST | Verifies credentials, then saves them |
| Disconnect | `/settings/disconnect_icloud_calendar` | POST | Clears stored credentials |
| Sync | `/settings/sync_icloud_calendar` | POST | Imports iCloud Calendar events as `CalendarEvent` records |

**Scope:** pull-only (iCloud → Season). No push.

`icloud_email` / `icloud_app_password` are stored per-user on the `users` table.

---

## 3. Microsoft Calendar (Outlook) — not built

Listed as "Coming soon" on Settings → Calendar. No setup exists yet.

---

## 4. Facebook OAuth (Meta / Facebook App)

1. [Meta Developers](https://developers.facebook.com/) → create or select an app
2. **App Settings > Basic** → copy **App ID** → `FACEBOOK_APP_ID`, **App Secret** → `FACEBOOK_APP_SECRET`
3. **Facebook Login > Settings** → add redirect URIs:
   - `https://seasonv2.onrender.com/users/auth/facebook/callback`
   - `http://localhost:3000/users/auth/facebook/callback`
4. Enable "Email" permission under Login Scopes

---

## 5. Apple Sign In (Apple Developer)

1. [Apple Developer Account](https://developer.apple.com/) → **Certificates, Identifiers & Profiles > Identifiers**
2. Create or use a Service ID (e.g. `com.seasonapp.web`)
3. Configure **Sign in with Apple** → add Return URLs:
   - `https://seasonv2.onrender.com/users/auth/apple/callback`
   - `http://localhost:3000/users/auth/apple/callback`
4. Create a Private Key for the Service ID (`.p8` file)
5. Env vars:
   - Service ID → `APPLE_CLIENT_ID`
   - Team ID (Membership page) → `APPLE_TEAM_ID`
   - Key ID → `APPLE_KEY_ID`
   - `.p8` file contents → `APPLE_PRIVATE_KEY` (line breaks as literal `\n`)

No `APPLE_CLIENT_SECRET` — the `omniauth-apple` gem generates the JWT client-side from the key.

---

## Render Dashboard Configuration

1. [Render Dashboard](https://dashboard.render.com/) → select the Season service → **Environment**
2. Add:

```
GOOGLE_CLIENT_ID=<value from Google Cloud>
GOOGLE_CLIENT_SECRET=<value from Google Cloud>
FACEBOOK_APP_ID=<value from Meta>
FACEBOOK_APP_SECRET=<value from Meta>
APPLE_CLIENT_ID=<value from Apple (Service ID)>
APPLE_TEAM_ID=<value from Apple Developer Membership>
APPLE_KEY_ID=<value from Apple Developer Keys>
APPLE_PRIVATE_KEY=<.p8 file content with literal \n for line breaks>
```

3. **Save Changes** — Render redeploys automatically

---

## Testing

**Local:** set the same variables in `.env`, run `bin/dev`, test login buttons at `/session/new`.

**Production:** after setting Render env vars —

1. Check **Logs** for Devise/OmniAuth errors
2. Test sign-in at `https://seasonv2.onrender.com/session/new`
3. Confirm each provider redirects, returns to `/calendar` or `/onboarding`, and creates a user record with the correct `{provider}_uid`

---

## Configuration Verification

```bash
grep -A 3 "config.omniauth" config/initializers/devise.rb
```

Expected:

```ruby
config.omniauth :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"],
  scope: "email,profile"
config.omniauth :facebook, ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_APP_SECRET"],
  scope: "email", prompt: "select_account"
config.omniauth :apple, ENV["APPLE_CLIENT_ID"], "",
  scope: "email name",
  team_id: ENV["APPLE_TEAM_ID"],
  key_id: ENV["APPLE_KEY_ID"],
  pem: ENV["APPLE_PRIVATE_KEY"]&.gsub("\\n", "\n")
```

A missing ENV var makes OmniAuth skip that provider silently.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Invalid OAuth credentials" | Client ID/Secret on provider dashboard must match Render env vars exactly |
| "Redirect URI mismatch" | Add the exact callback URL to the provider's authorized list |
| Provider button not showing | Check env vars are set on Render |
| Silent OmniAuth failure | Check Rails logs for `devise.omniauth` warnings |
| iCloud "Connection failed" | Regenerate the app-specific password; confirm the Apple ID email is correct |

---

## Security Notes

- `*_SECRET` and `*_PASSWORD` values are never committed to Git
- Render env vars: manual entry only (`sync: false`), same as `RESEND_API_KEY`
- Use different credentials for local dev vs production
- Rotate secrets periodically

---

## Status

**As of 2026-09-19 13:51 UTC**

| Area | Status |
|------|--------|
| Google login | ✅ Live on Render, any user |
| Facebook login | ✅ Live on Render |
| Apple login | ✅ Live on Render |
| Google Calendar sync | ✅ Pull + push, verified against a real account |
| iCloud Calendar sync | ✅ Pull only |
| Microsoft Calendar sync | ⬜ Not built |
| Google verification (Calendar scope) | ⬜ Not submitted — Calendar Sync capped to a manual test-user allowlist until done |
| Per-provider sync-direction setting (pull/push/both, user-selectable) | ⬜ Not built — currently fixed per provider (Google: both, iCloud: pull only), pending team decision |

| Provider | Credentials | On Render | Callback URL |
|----------|-------------|-----------|--------------|
| Google | ✅ | ✅ | `https://seasonv2.onrender.com/users/auth/google_oauth2/callback` |
| Facebook | ✅ | ✅ | `https://seasonv2.onrender.com/users/auth/facebook/callback` |
| Apple | ✅ | ✅ | `https://seasonv2.onrender.com/users/auth/apple/callback` |
