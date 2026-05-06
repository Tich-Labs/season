# OAuth Fix for Season App
## Problem Analysis

You have **TWO competing OAuth systems** that conflict:

### System 1: Devise OmniAuth (Primary)
- **Config**: `config/initializers/devise.rb` (lines 277-279)
- **Routes**: `routes.rb` line 77-84 (`devise_for :users`)
- **Controller**: `app/controllers/users/omniauth_callbacks_controller.rb`
- **Callback URL**: `/users/auth/:provider/callback`

### System 2: Custom OmniAuth (Conflicting)
- **Controller**: `app/controllers/omniauth_controller.rb`
- **Routes**: `routes.rb` line 98 (`match "/auth/:provider/callback"`)
- **Callback URL**: `/auth/:provider/callback`

### The Conflict
When OAuth provider redirects back, **BOTH systems try to handle it**, causing:
- Double callback processing
- Route conflicts
- Session/login issues on different screens
- Auth failures

---

## Solution: Remove Custom System, Keep Devise OmniAuth

### Step 1: Remove Custom OmniAuth Controller
```bash
rm /Users/tichlabs/Documents/onlyCode/season/app/controllers/omniauth_controller.rb
```

### Step 2: Remove Custom Route from routes.rb
Edit `config/routes.rb` - **DELETE** line 97-98:
```ruby
# DELETE THESE LINES:
get "/auth/failure", to: "omniauth#failure"
match "/auth/:provider/callback", to: "omniauth#callback", via: [:get, :post]
```

### Step 3: Update Devise Configuration
Ensure `config/initializers/devise.rb` has correct OmniAuth setup (lines 277-279):
```ruby
config.omniauth :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"], scope: "email,profile", prompt: "select_account"
config.omniauth :facebook, ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_APP_SECRET"], scope: "public_profile,email", info_fields: "email,name"
config.omniauth :apple, ENV["APPLE_CLIENT_ID"], ENV["APPLE_CLIENT_SECRET"], scope: "email, name"
```

### Step 4: Fix OmniAuth Callbacks Controller
Update `app/controllers/users/omniauth_callbacks_controller.rb` to handle the proper Devise flow:

```ruby
module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # Skip CSRF for OAuth callbacks (they come from external providers)
    skip_before_action :verify_authenticity_token, only: [:google_oauth2, :facebook, :apple]
    
    # Allow unauthenticated access (users are trying to log in)
    allow_unauthenticated_access
    skip_onboarding_requirement

    def google_oauth2
      handle_oauth("google")
    end

    def facebook
      handle_oauth("facebook")
    end

    def apple
      handle_oauth("apple")
    end

    def failure
      redirect_to new_session_path, alert: I18n.t("oauth.errors.authentication_failed")
    end

    private

    def handle_oauth(provider_name)
      auth = request.env["omniauth.auth"]
      
      unless auth
        redirect_to new_session_path, alert: I18n.t("oauth.errors.authentication_failed")
        return
      end

      # Extract email from auth hash
      email = auth.dig("info", "email") || auth.dig("extra", "raw_info", "email")
      
      if email.blank?
        redirect_to new_session_path, alert: I18n.t("oauth.errors.email_required", provider: provider_name.to_s.titleize)
        return
      end

      # Find or create user from OAuth
      user = User.find_or_create_from_oauth(provider_name, auth)

      if user.persisted?
        # Sign in the user (Devise method)
        sign_in user
        redirect_to after_sign_in_path_for(user)
      else
        redirect_to new_session_path, alert: I18n.t("oauth.errors.creation_failed")
      end
    end
  end
end
```

### Step 5: Ensure User Model Handles OAuth
Your `User` model (lines 75-99) has `find_or_create_from_oauth` - **this is correct**.

Make sure `user.rb` includes (line 5):
```ruby
devise :omniauthable, omniauth_providers: [:google_oauth2, :facebook, :apple]
```

### Step 6: Set Environment Variables
OAuth fails if credentials are missing. Check:

1. **Development** (`.env` or credentials):
```bash
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
FACEBOOK_APP_ID=your_facebook_app_id
FACEBOOK_APP_SECRET=your_facebook_app_secret
APPLE_CLIENT_ID=your_apple_client_id
APPLE_CLIENT_SECRET=your_apple_private_key
```

2. **Production (Render Dashboard)**:
   - Set all 6 environment variables
   - Add Render app URL to OAuth provider redirect URIs

### Step 7: Add Client Secrets to Credentials (Optional)
For better security, store secrets in `credentials.yml.enc`:

```bash
bin/rails credentials:edit
```

Add:
```yaml
google:
  client_id: "xxx"
  client_secret: "xxx"
facebook:
  app_id: "xxx"
  app_secret: "xxx"
apple:
  client_id: "xxx"
  team_id: "xxx"
  key_id: "xxx"
  private_key: |
    -----BEGIN PRIVATE KEY-----
    ...
    -----END PRIVATE KEY-----
```

Then update `devise.rb`:
```ruby
config.omniauth :google_oauth2, Rails.application.credentials.dig(:google, :client_id), Rails.application.credentials.dig(:google, :client_secret)
```

---

## OAuth Provider Configuration

### Google OAuth2
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create OAuth2 client ID
3. **Authorized redirect URIs**:
   - Development: `http://localhost:3000/users/auth/google_oauth2/callback`
   - Production: `https://your-app.onrender.com/users/auth/google_oauth2/callback`

### Facebook OAuth
1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create app → Add Facebook Login product
3. **Valid OAuth Redirect URIs**:
   - `https://your-app.onrender.com/users/auth/facebook/callback`

### Apple Sign In
1. Go to [Apple Developer](https://developer.apple.com/)
2. Certificates, Identifiers & Profiles → Keys → Create
3. Enable **Sign In with Apple**
4. **Return URL**: `https://your-app.onrender.com/users/auth/apple/callback`

---

## Testing OAuth

### Development Testing
```bash
# Start server
bin/dev

# Test Google OAuth
open http://localhost:3000/users/auth/google_oauth2

# Test Facebook OAuth
open http://localhost:3000/users/auth/facebook

# Test Apple OAuth
open http://localhost:3000/users/auth/apple
```

### Check Logs
```bash
tail -f log/development.log | grep -i "omniauth\|oauth\|auth"
```

### Common Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `redirect_uri_mismatch` | OAuth provider config wrong | Add correct callback URL to provider settings |
| `invalid_credentials` | Wrong client ID/secret | Check ENV vars or credentials |
| `email not found` | Provider not returning email | Check scope: "email,profile" |
| `csrf_detected` | CSRF token issue | Ensure `skip_before_action :verify_authenticity_token` in callbacks controller |
| `user not persisted` | Validation failed | Check User model validations (name, etc.) |

---

## Summary of Changes Needed

1. ✅ **DELETE** `app/controllers/omniauth_controller.rb`
2. ✅ **DELETE** custom OAuth routes (lines 97-98 in `routes.rb`)
3. ✅ **UPDATE** `users/omniauth_callbacks_controller.rb` (use Devise's `sign_in` method)
4. ✅ **VERIFY** `config/initializers/devise.rb` has correct `config.omniauth` lines
5. ✅ **SET** OAuth credentials in ENV or credentials
6. ✅ **CONFIGURE** OAuth providers with correct callback URLs

After these changes, OAuth will use **ONLY Devise OmniAuth** (System 1), eliminating the conflicts.
