require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
    Rails.cache.clear
  end

  # --- POST /session (create) ---

  test "POST /session with valid credentials redirects to calendar" do
    post session_path, params: {email: @alice.email, password: "password123"}
    assert_redirected_to user_root_path
  end

  test "POST /session with valid credentials for incomplete onboarding redirects to onboarding" do
    carol = users(:carol)
    post session_path, params: {email: carol.email, password: "password123"}
    assert_redirected_to onboarding_path(2)
  end

  test "POST /session with wrong password renders login with 422" do
    post session_path, params: {email: @alice.email, password: "wrongpassword"}
    assert_response :unprocessable_entity
  end

  test "POST /session with unknown email renders login with 422" do
    post session_path, params: {email: "nobody@example.com", password: "password123"}
    assert_response :unprocessable_entity
  end

  test "POST /session with blank email renders login with 422" do
    post session_path, params: {email: "", password: "password123"}
    assert_response :unprocessable_entity
  end

  # --- Cookie expiry behavior (web and native are both persistent) ---

  test "POST /session from web sets permanent (20-year) user_id cookie" do
    post session_path, params: {email: @alice.email, password: "password123"}
    set_cookies = Array(response.headers["Set-Cookie"])
    uid_cookie = set_cookies.find { |c| c.start_with?("user_id=") }
    assert_includes uid_cookie, "expires="
    expires = uid_cookie.match(/expires=([^;]+)/)[1]
    assert_in_delta 20.years.from_now, Time.zone.parse(expires), 5.seconds
  end

  test "POST /session from native sets permanent (20-year) user_id cookie" do
    post session_path, params: {email: @alice.email, password: "password123"},
      headers: {"User-Agent" => "Hotwire Native iOS"}
    set_cookies = Array(response.headers["Set-Cookie"])
    uid_cookie = set_cookies.find { |c| c.start_with?("user_id=") }
    assert_includes uid_cookie, "expires="
    expires = uid_cookie.match(/expires=([^;]+)/)[1]
    assert_in_delta 20.years.from_now, Time.zone.parse(expires), 5.seconds
  end

  # --- Long-lived session persistence ---

  test "native session survives past the old 7-day boundary" do
    post session_path, params: {email: @alice.email, password: "password123"},
      headers: {"User-Agent" => "Hotwire Native iOS"}

    travel_to 10.days.from_now do
      get tracking_index_path
      assert_response :success
    end
  end

  test "web session also survives past the old 7-day boundary" do
    post session_path, params: {email: @alice.email, password: "password123"}

    travel_to 10.days.from_now do
      get tracking_index_path
      assert_response :success
    end
  end

  # --- Logout revokes permanent cookie ---

  test "DELETE /session revokes permanent native cookie" do
    post session_path, params: {email: @alice.email, password: "password123"},
      headers: {"User-Agent" => "Hotwire Native iOS"}
    delete session_path
    assert_redirected_to root_path

    get tracking_index_path
    assert_redirected_to new_session_path
  end

  # --- Unauthenticated redirect ---

  test "unauthenticated request redirects to login for web" do
    get tracking_index_path
    assert_redirected_to new_session_path
  end

  test "unauthenticated request redirects to root for native" do
    get tracking_index_path, headers: {"User-Agent" => "Hotwire Native iOS"}
    assert_redirected_to root_path
  end

  # --- Google OAuth ---

  test "OmniAuth restricts callback hosts" do
    assert_includes OmniAuth.config.allowed_hosts, "seasonv2.onrender.com"
    assert_includes OmniAuth.config.allowed_hosts, "www.example.com"
  end

  test "native WebView user agent bypasses the OmniAuth CSRF check" do
    OmniAuth.config.test_mode = false

    post user_google_oauth2_omniauth_authorize_path,
      headers: {"User-Agent" => "Season Native/1.0 (iPhone; iOS 18.0)"}

    assert_response :redirect
    assert_equal "accounts.google.com", URI(response.location).host
  ensure
    OmniAuth.config.test_mode = false
  end

  test "Google sign-in does not overwrite Google Calendar tokens" do
    @alice.update_columns(
      google_access_token: "calendar-access-token",
      google_refresh_token: "calendar-refresh-token",
      google_token_expires_at: 1.hour.from_now,
      google_calendar_email: @alice.email
    )

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "google-login-uid",
      info: {email: @alice.email, name: @alice.name},
      credentials: {
        token: "basic-scope-token",
        refresh_token: "basic-scope-refresh-token",
        expires_at: 1.hour.from_now.to_i,
        scope: "email profile"
      }
    )

    get user_google_oauth2_omniauth_callback_path

    @alice.reload
    assert_equal "calendar-access-token", @alice.google_access_token
    assert_equal "calendar-refresh-token", @alice.google_refresh_token
    assert_equal @alice.email, @alice.google_calendar_email
  ensure
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end
end
