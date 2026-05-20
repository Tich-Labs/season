# Turbo Native integration — configures native-specific Rails behaviour.
#
# Detection:  TurboNativeDetection concern (app/controllers/concerns/)
#   - Checks HTTP_X_HOTWIRE_NATIVE header + Turbo Native user agent
#   - Sets request.variant = :turbo_native  → enables +turbo_native.erb templates
#   - Authenticates via X-Turbo-Native-Token header
#
# Auth token: has_secure_token :native_auth_token on User model
#   - Generated at user creation (has_secure_token)
#   - Regenerated on every native login (Authentication#login)
#   - Injected via <meta name="native-auth-token"> in application layout
#
# iOS:       ios/SeasonApp/ — TurboNavigator with tab bar
#   - Base URL from SEASON_BASE_URL in Info.plist
#   - Path rules: GET /configurations/ios_v1.json

Rails.application.config.turbo_native_enabled = true
