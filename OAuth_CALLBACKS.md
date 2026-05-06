# OAuth Callback URLs - Season V2

**Version:** 1.0 (2026-05-06)  
**Updated:** 2026-05-06 09:26  
**Changes:** Initial version with correct Devise OAuth callback URLs for seasonv2.onrender.com

---

## Render URL: `https://seasonv2.onrender.com/`

---

## Correct Callback URLs for Season V2

### Facebook
```
https://seasonv2.onrender.com/users/auth/facebook/callback
```

### Google
```
https://seasonv2.onrender.com/users/auth/google_oauth2/callback
```

### Apple
```
https://seasonv2.onrender.com/users/auth/apple/callback
```

---

## Update These in Provider Consoles

### 1. Facebook Developers
1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Select your Season app
3. **Facebook Login** → **Settings**
4. **Valid OAuth Redirect URIs** - ADD:
   ```
   https://seasonv2.onrender.com/users/auth/facebook/callback
   ```
5. REMOVE old URL (if any): `https://seasonv2.onrender.com/auth/facebook/callback`
6. Click **Save Changes**

### 2. Google Cloud Console
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. **APIs & Services** → **Credentials**
4. Edit your OAuth 2.0 Client ID
5. **Authorized redirect URIs** - ADD:
   ```
   https://seasonv2.onrender.com/users/auth/google_oauth2/callback
   ```
6. Click **Save**

### 3. Apple Developer
1. Go to [Apple Developer](https://developer.apple.com/)
2. **Certificates, Identifiers & Profiles** → **Keys**
3. Select your Sign In with Apple key
4. **Add Website URL** and **Return URLs** - ADD:
   ```
   https://seasonv2.onrender.com/users/auth/apple/callback
   ```
5. Click **Save**

---

## Environment Variables to Set in Render Dashboard

Go to **Render Dashboard** → **seasonv2** → **Environment**:

### ✅ Google (Ready to Add)
```
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
```
**Status:** ✅ Credentials ready - adding to Render now

### ⏳ Facebook (Pending)
```
FACEBOOK_APP_ID=your_facebook_app_id
FACEBOOK_APP_SECRET=your_facebook_app_secret
```
**Status:** ⏳ Credentials identified - need to add to Render

### ❌ Apple (Waiting for Dev Account)
```
APPLE_CLIENT_ID=your_apple_service_id
APPLE_TEAM_ID=your_team_id
APPLE_KEY_ID=your_key_id
APPLE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----
your_private_key_here
-----END PRIVATE KEY-----
```
**Status:** ❌ Waiting for Apple Developer Account approval

---

**Important:** For `APPLE_PRIVATE_KEY`, paste the entire key including `-----BEGIN/END-----` lines.

---

## Verify Routes (Local Testing)

```bash
cd /Users/tichlabs/Documents/onlyCode/season
bin/rails routes | grep omniauth_callback
```

Expected output:
```
user_omniauth_callback GET|POST /users/auth/:action/callback(.:format) users/omniauth_callbacks#(?-mix:facebook|google_oauth2|apple)
```

---

## Test OAuth Login

### Local Development:
```bash
bin/dev
```

Visit:
- Facebook: `http://localhost:3000/users/auth/facebook`
- Google: `http://localhost:3000/users/auth/google_oauth2`
- Apple: `http://localhost:3000/users/auth/apple`

### Production:
Visit `https://seasonv2.onrender.com/session/new` and click the OAuth buttons.

---

## Quick Copy-Paste URLs

### For Google Cloud Console: ✅ Ready
```
https://seasonv2.onrender.com/users/auth/google_oauth2/callback
```
**Status:** ✅ Add to Google Cloud Console → APIs & Services → Credentials → OAuth 2.0 Client → Authorized redirect URIs

### For Facebook Developers Console: ⏳ Pending
```
https://seasonv2.onrender.com/users/auth/facebook/callback
```
**Status:** ⏳ Update in Facebook Developers → Your App → Facebook Login → Settings → Valid OAuth Redirect URIs

### For Apple Developer: ❌ Waiting for Dev Account
```
https://seasonv2.onrender.com/users/auth/apple/callback
```
**Status:** ❌ Add once Apple Developer Account is approved

---

## Common Errors & Fixes

### Error: `redirect_uri_mismatch`
**Cause:** Callback URL in provider console doesn't match Devise route.

**Fix:** Copy the **exact URLs above** into each provider's console.

### Error: `invalid_client` / `unauthorized`
**Cause:** Wrong client ID or secret.

**Fix:** Verify environment variables in Render dashboard match the credentials in provider consoles.

### Error: `csrf_detected`
**Cause:** CSRF token issue with OAuth.

**Fix:** Already fixed - `skip_before_action :verify_authenticity_token` in `omniauth_callbacks_controller.rb`.

---

## Summary Checklist

### Facebook
- [ ] Update **Valid OAuth Redirect URIs** to: `https://seasonv2.onrender.com/users/auth/facebook/callback`
- [ ] Set `FACEBOOK_APP_ID` in Render
- [ ] Set `FACEBOOK_APP_SECRET` in Render

### Google
- [ ] Update **Authorized redirect URIs** to: `https://seasonv2.onrender.com/users/auth/google_oauth2/callback`
- [ ] Set `GOOGLE_CLIENT_ID` in Render
- [ ] Set `GOOGLE_CLIENT_SECRET` in Render

### Apple
- [ ] Update **Return URLs** to: `https://seasonv2.onrender.com/users/auth/apple/callback`
- [ ] Set `APPLE_CLIENT_ID` in Render
- [ ] Set `APPLE_TEAM_ID` in Render
- [ ] Set `APPLE_KEY_ID` in Render
- [ ] Set `APPLE_PRIVATE_KEY` in Render

---

**Render URL:** `https://seasonv2.onrender.com/`  
**Updated:** 2026-05-06  
**File:** `/Users/tichlabs/Documents/onlyCode/season/OAuth_CALLBACKS.md`
