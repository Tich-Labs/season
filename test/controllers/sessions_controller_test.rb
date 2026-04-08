require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
    Rails.cache.clear
  end

  # --- POST /session (create) ---

  test "POST /session with valid credentials redirects to calendar" do
    post session_path, params: { email: @alice.email, password: "password123" }
    assert_redirected_to user_root_path
  end

  test "POST /session with valid credentials for incomplete onboarding redirects to onboarding" do
    carol = users(:carol)
    post session_path, params: { email: carol.email, password: "password123" }
    assert_redirected_to onboarding_path(1)
  end

  test "POST /session with wrong password renders login with 422" do
    post session_path, params: { email: @alice.email, password: "wrongpassword" }
    assert_response :unprocessable_entity
  end

  test "POST /session with unknown email renders login with 422" do
    post session_path, params: { email: "nobody@example.com", password: "password123" }
    assert_response :unprocessable_entity
  end

  test "POST /session with blank email renders login with 422" do
    post session_path, params: { email: "", password: "password123" }
    assert_response :unprocessable_entity
  end

  # --- DELETE /session (destroy) ---

  test "DELETE /session signs out the user and redirects to root" do
    sign_in_as(@alice)
    delete session_path
    assert_redirected_to root_path
  end

  test "DELETE /session clears the session so subsequent requests are unauthenticated" do
    sign_in_as(@alice)
    delete session_path
    get user_root_path
    assert_redirected_to new_session_path
  end
end
