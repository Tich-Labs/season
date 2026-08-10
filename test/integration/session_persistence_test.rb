require "test_helper"

class SessionPersistenceTest < ActionDispatch::IntegrationTest
  def onboarded_user(email:)
    User.create!(
      email: email, name: "Test", password: "CorrectHorse123!", password_confirmation: "CorrectHorse123!",
      birthday: 30.years.ago, has_regular_cycle: true, uses_hormonal_birth_control: false,
      food_preference: "omnivore", onboarding_completed: true
    ).tap(&:confirm)
  end

  test "login always lands on the monthly calendar, even after trying a deep link first" do
    user = onboarded_user(email: "deeplinktest@example.com")

    # Try to hit a protected deep link while logged out.
    get superpowers_path
    assert_redirected_to new_session_path

    post session_path, params: {email: user.email, password: "CorrectHorse123!"}
    assert_redirected_to user_root_path
  end

  test "web session cookie has no expiry (persistent until logout)" do
    user = onboarded_user(email: "persistsession@example.com")
    post session_path, params: {email: user.email, password: "CorrectHorse123!"}
    assert_response :redirect

    set_cookie_lines = Array(response.headers["Set-Cookie"])
    user_id_cookie_line = set_cookie_lines.find { |line| line.start_with?("user_id=") }
    assert user_id_cookie_line.present?, "expected a user_id cookie to be set"

    expires_str = user_id_cookie_line[/expires=([^;]+)/i, 1]
    expires_at = Time.httpdate(expires_str)
    assert expires_at > 10.years.from_now, "cookie should expire far in the future (permanent), got #{expires_at}"
  end

  test "logging out clears the session" do
    user = onboarded_user(email: "logouttest@example.com")
    post session_path, params: {email: user.email, password: "CorrectHorse123!"}

    delete session_path
    get user_root_path
    assert_redirected_to new_session_path
  end
end
