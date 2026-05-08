# M2 OAuth Credentials Setup — Render Deployment

**Version:** 2.1 (2026-05-06)  
**Updated:** 2026-05-06 12:15  
**Changes:** Facebook OAuth ✅ working, updated status table, all credentials ready

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
| `APPLE_CLIENT_ID` | Apple Developer | Service ID / Bundle ID |
| `APPLE_CLIENT_SECRET` | Apple Developer | Private key (JWT) |

---

## Setup Instructions

### 1. Google OAuth (Google Cloud Console)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or use an existing one
3. Navigate to **APIs & Services > Credentials**
4. Click **Create Credentials > OAuth 2.0 Client ID**
5. Choose **Web Application**
6. Under **Authorized redirect URIs**, add:
   - `https://seasonv2.onrender.com/users/auth/google_oauth2/callback`
   - `http://localhost:3000/users/auth/google_oauth2/callback` (local dev)
7. Copy **Client ID** → `GOOGLE_CLIENT_ID`
8. Copy **Client Secret** → `GOOGLE_CLIENT_SECRET`

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
5. Create a **Private Key** for the Service ID
6. Download the key and generate JWT token:
   - Use Team ID, Key ID, and private key to create JWT
   - Service ID → `APPLE_CLIENT_ID`
   - JWT token → `APPLE_CLIENT_SECRET`

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
APPLE_CLIENT_ID=<value from Apple>
APPLE_CLIENT_SECRET=<JWT from Apple>
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
APPLE_CLIENT_SECRET=<dev_jwt>
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
  scope: "email,profile", prompt: "select_account"
config.omniauth :facebook, ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_APP_SECRET"],
  scope: "email", prompt: "select_account"
config.omniauth :apple, ENV["APPLE_CLIENT_ID"], ENV["APPLE_CLIENT_SECRET"],
  scope: "email, name"
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

> **Updated 8 May 2026** — Google and Facebook are live on Render. Apple pending.

| Area | Status |
|------|--------|
| Rails config (`devise.rb`) | ✅ Complete |
| Callbacks controller | ✅ Complete |
| Custom OAuth conflicts | ✅ Removed — Devise only |
| Google on Render | ✅ Live |
| Facebook on Render | ✅ Live |
| Apple on Render | ⏳ Waiting for Apple Developer Account |

---

### Provider Detail

| Provider | Credentials | On Render | Callback URL |
|----------|-------------|-----------|--------------|
| **Google** | ✅ Obtained | ✅ Set | `https://seasonv2.onrender.com/users/auth/google_oauth2/callback` |
| **Facebook** | ✅ Obtained | ✅ Set | `https://seasonv2.onrender.com/users/auth/facebook/callback` |
| **Apple** | ⏳ Pending | ⏳ Pending | `https://seasonv2.onrender.com/users/auth/apple/callback` |

**Callback pattern:** `/users/auth/:provider/callback` (Devise default)

### What's left

- [ ] Apple Developer Account approval → obtain `APPLE_CLIENT_ID` + `APPLE_CLIENT_SECRET`
- [ ] Set Apple vars on Render → OAuth fully complete across all three providers
