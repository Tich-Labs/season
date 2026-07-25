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

  # --- Cookie expiry behavior (web vs native) ---

  test "POST /session from web sets 7-day user_id cookie" do
    post session_path, params: {email: @alice.email, password: "password123"}
    set_cookies = Array(response.headers["Set-Cookie"])
    uid_cookie = set_cookies.find { |c| c.start_with?("user_id=") }
    assert_includes uid_cookie, "expires="
    expires = uid_cookie.match(/expires=([^;]+)/)[1]
    assert_in_delta 7.days.from_now, Time.zone.parse(expires), 5.seconds
  end

  test "POST /session from native sets permanent (20-year) user_id cookie" do
    post session_path, params: {email: @alice.email, password: "password123"},
      headers: {"User-Agent" => "Ruby Native iOS"}
    set_cookies = Array(response.headers["Set-Cookie"])
    uid_cookie = set_cookies.find { |c| c.start_with?("user_id=") }
    assert_includes uid_cookie, "expires="
    expires = uid_cookie.match(/expires=([^;]+)/)[1]
    assert_in_delta 20.years.from_now, Time.zone.parse(expires), 5.seconds
  end

  # --- Long-lived session persistence ---

  test "native session survives past old 7-day boundary" do
    post session_path, params: {email: @alice.email, password: "password123"},
      headers: {"User-Agent" => "Ruby Native iOS"}

    travel_to 10.days.from_now do
      get tracking_index_path
      assert_response :success
    end
  end

  test "web session expires after session cookie expiry (7 days)" do
    post session_path, params: {email: @alice.email, password: "password123"}

    travel_to 10.days.from_now do
      cookies.delete("user_id")
      get tracking_index_path
      assert_redirected_to new_session_path
    end
  end

  # --- Logout revokes permanent cookie ---

  test "DELETE /session revokes permanent native cookie" do
    post session_path, params: {email: @alice.email, password: "password123"},
      headers: {"User-Agent" => "Ruby Native iOS"}
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
    get tracking_index_path, headers: {"User-Agent" => "Ruby Native iOS"}
    assert_redirected_to root_path
  end
end
