---
layout: default
---

# M2 OAuth Credentials Setup — Render Deployment

**Version:** 4.0 (2026-07-19)  
**Updated:** 2026-07-19  
**Changes:** Google Calendar API scope added, offline access, token persistence, Google OAuth consent screen now requests calendar scopes

---

## Overview

OAuth social login (Google, Facebook, Apple) is fully configured in the Rails app via **Devise OmniAuth**. This document covers the **Render dashboard configuration** required to complete M2.

**Important:** Season uses **Devise OmniAuth only** (custom `OmniauthController` was removed). All callback URLs follow the Devise pattern:
```
/users/auth/:provider/callback
```

All OAuth environment variables are configured in `config/initializers/devise.rb` and already reference the correct ENV vars. They just need values set on Render.

---

## Environment Variables Required

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

---

## Setup Instructions

### 1. Google OAuth (Google Cloud Console)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or use an existing one
3. Navigate to **APIs & Services > Library** and enable **Google Calendar API**
4. Navigate to **APIs & Services > OAuth consent screen**
   - Add scope: `https://www.googleapis.com/auth/calendar` (View and manage calendars)
5. Navigate to **APIs & Services > Credentials**
6. Click **Create Credentials > OAuth 2.0 Client ID**
7. Choose **Web Application**
8. Under **Authorized redirect URIs**, add:

   **For Login (via Devise OmniAuth):**
   - `https://seasonv2.onrender.com/users/auth/google_oauth2/callback`
   - `http://localhost:3000/users/auth/google_oauth2/callback` (local dev)

   **For Calendar Sync (via Settings page — `/settings/calendar`):**
   - `https://seasonv2.onrender.com/settings/google_calendar_callback`
   - `http://127.0.0.1:3000/settings/google_calendar_callback` (local dev)

   > The Calendar Sync flow uses a separate OAuth dance initiated from the Settings page, NOT the Devise login flow. Both callback URLs must be registered.

9. Copy **Client ID** → `GOOGLE_CLIENT_ID`
10. Copy **Client Secret** → `GOOGLE_CLIENT_SECRET`

### 1b. Google Calendar Sync (Settings → Calendar)

In addition to login OAuth, the app supports **Google Calendar sync** from the user's Settings page (`/settings/calendar`). This uses a separate OAuth flow (not Devise OmniAuth) built with `Signet::OAuth2::Client` directly:

| Action | Route | Method | Description |
|--------|-------|--------|-------------|
| Connect | `/settings/connect_google_calendar` | GET | Builds OAuth URL and redirects to Google consent |
| Callback | `/settings/google_calendar_callback` | GET | Exchanges auth code for access/refresh tokens |
| Disconnect | `/settings/disconnect_google_calendar` | POST | Clears stored tokens |
| Sync | `/settings/sync_google_calendar` | POST | Imports Google Calendar events as `CalendarEvent` records |

**Flow:**
1. User clicks **Connect** on `/settings/calendar`
2. Redirected to Google consent screen (scope: `https://www.googleapis.com/auth/calendar`, offline access)
3. After authorization, Google redirects to `/settings/google_calendar_callback?code=...`
4. Server exchanges code for tokens and stores them on the User record
5. User can then click **Sync now** to import events

**Required Google Cloud Console setup:**
- Add redirect URI: `http://127.0.0.1:3000/settings/google_calendar_callback` (dev) and `https://seasonv2.onrender.com/settings/google_calendar_callback` (prod)
- OAuth consent scope: `https://www.googleapis.com/auth/calendar` (already required for login)

**Env vars for `.env` file:**
```bash
GOOGLE_CLIENT_ID=your_client_id_here
GOOGLE_CLIENT_SECRET=your_client_secret_here
```

The same `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` are used for both login and calendar sync — Google differentiates them by callback URL.

**Error: `Missing required parameter: client_id`** — means `GOOGLE_CLIENT_ID` is not set or empty. Add it to `.env` and restart `bin/dev`.

---

### 2. Facebook OAuth (Meta / Facebook App)

1. Go to [Meta Developers](https://developers.facebook.com/)
2. Create a new app or use existing one
3. Navigate to **App Settings > Basic**
4. Copy **App ID** → `FACEBOOK_APP_ID`
5. Copy **App Secret** → `FACEBOOK_APP_SECRET`
6. Under **Facebook Login > Settings**, add redirect URIs:
   - `https://seasonv2.onrender.com/users/auth/facebook/callback`
   - `http://localhost:3000/users/auth/facebook/callback`
7. Ensure "Email" permission is enabled in Login Scopes

---

### 3. Apple Sign In (Apple Developer)

1. Go to [Apple Developer Account](https://developer.apple.com/)
2. Navigate to **Certificates, Identifiers & Profiles > Identifiers**
3. Create or use an existing Service ID (e.g., `com.seasonapp.web`)
4. Configure **Sign in with Apple**:
   - Add **Return URLs**:
     - `https://seasonv2.onrender.com/users/auth/apple/callback`
     - `http://localhost:3000/users/auth/apple/callback`
5. Create a **Private Key** for the Service ID (`.p8` file)
6. Configure the Rails app with these env vars (the `omniauth-apple` gem generates the JWT client-side):
   - Service ID → `APPLE_CLIENT_ID`
   - Team ID (from Membership) → `APPLE_TEAM_ID`
   - Key ID (from the created key) → `APPLE_KEY_ID`
   - Private key `.p8` file contents → `APPLE_PRIVATE_KEY` (with `\n` line breaks as literal `\n`)
7. The actual `config/initializers/devise.rb` line:
   ```ruby
   config.omniauth :apple, ENV["APPLE_CLIENT_ID"], "",
     scope: "email name",
     team_id: ENV["APPLE_TEAM_ID"],
     key_id: ENV["APPLE_KEY_ID"],
     pem: ENV["APPLE_PRIVATE_KEY"]&.gsub("\\n", "\n")
   ```
   **Note:** The password field is empty string `""` (the gem handles key-based signing, not client secret). The `.p8` key content must have `\n` as literal two-character escape sequences (Render env var format), then `gsub` converts them to actual newlines at runtime.

---

## Render Dashboard Configuration

1. Go to [Render Dashboard](https://dashboard.render.com/)
2. Select your Season app service
3. Navigate to **Environment**
4. Add the following variables:

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

5. Click **Save Changes**
6. Render will automatically redeploy with new environment variables

---

## Testing

### Local Development

Set env vars in `.env` or `.env.local`:

```bash
GOOGLE_CLIENT_ID=<dev_client_id>
GOOGLE_CLIENT_SECRET=<dev_client_secret>
FACEBOOK_APP_ID=<dev_app_id>
FACEBOOK_APP_SECRET=<dev_app_secret>
APPLE_CLIENT_ID=<dev_service_id>
APPLE_TEAM_ID=<dev_team_id>
APPLE_KEY_ID=<dev_key_id>
APPLE_PRIVATE_KEY=<dev_p8_content_with_literal_\n>
```

Run `bin/dev` and test login buttons at `/session/new`.

### Production

After setting env vars on Render:

1. Check **Logs** for any Devise/OmniAuth initialization errors
2. Test sign-in flow at `https://seasonv2.onrender.com/session/new`
3. Click each provider button and verify:
   - Redirect to provider login
   - Callback returns user to `/calendar` or `/onboarding`
   - User record created with correct `{provider}_uid` field

---

## Configuration Verification

To verify OAuth is correctly wired in Rails:

```bash
cd /path/to/season
grep -A 3 "config.omniauth" config/initializers/devise.rb
```

Expected output:

```ruby
config.omniauth :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"],
  scope: "email,profile,https://www.googleapis.com/auth/calendar",
  access_type: "offline",
  prompt: "consent"
config.omniauth :facebook, ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_APP_SECRET"],
  scope: "email", prompt: "select_account"
config.omniauth :apple, ENV["APPLE_CLIENT_ID"], "",
  scope: "email name",
  team_id: ENV["APPLE_TEAM_ID"],
  key_id: ENV["APPLE_KEY_ID"],
  pem: ENV["APPLE_PRIVATE_KEY"]&.gsub("\\n", "\n")
```

If any ENV var is missing, OmniAuth will skip that provider silently.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Invalid OAuth credentials" | Verify Client IDs/Secrets on provider dashboard match Render env vars exactly |
| "Redirect URI mismatch" | Add full callback URL to authorized URIs list on each provider |
| Provider button not showing | Check `render.yaml` or Render dashboard env vars are set |
| Silent OmniAuth failure | Check Rails logs for `devise.omniauth` warnings |

---

## Security Notes

- All `*_SECRET` values are **never committed** to Git
- Render marks `RESEND_API_KEY` as `sync: false` in `render.yaml` — OAuth vars should follow the same pattern (manual entry only)
- Use different credentials for local dev vs production
- Rotate secrets periodically via provider dashboards

---

## Status

> **Updated 19 Jul 2026** — All three providers live on Render. Google Calendar API integration added.

| Area | Status |
|------|--------|
| Rails config (`devise.rb`) | ✅ Complete |
| Callbacks controller | ✅ Complete |
| Custom OAuth conflicts | ✅ Removed — Devise only |
| Google on Render | ✅ Live |
| Google Calendar API scope | ✅ Added (`calendar`, offline access) |
| Google Calendar token storage | ✅ Complete (access + refresh token persisted) |
| GoogleCalendarService | ✅ Complete (list/create/delete events) |
| Facebook on Render | ✅ Live |
| Apple on Render | ✅ Live |

---

### Provider Detail

| Provider | Credentials | On Render | Callback URL |
|----------|-------------|-----------|--------------|
| **Google** | ✅ Obtained | ✅ Set | `https://seasonv2.onrender.com/users/auth/google_oauth2/callback` |
| **Facebook** | ✅ Obtained | ✅ Set | `https://seasonv2.onrender.com/users/auth/facebook/callback` |
| **Apple** | ✅ Obtained (Service ID + `.p8` key) | ✅ Set | `https://seasonv2.onrender.com/users/auth/apple/callback` |

**Callback pattern:** `/users/auth/:provider/callback` (Devise default)

**Apple Note:** Uses `APPLE_TEAM_ID`, `APPLE_KEY_ID`, `APPLE_PRIVATE_KEY` (`.p8` file). The `omniauth-apple` gem generates the JWT client-side — no `APPLE_CLIENT_SECRET` env var needed.
