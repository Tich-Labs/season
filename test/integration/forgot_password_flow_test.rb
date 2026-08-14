require "test_helper"

class ForgotPasswordFlowTest < ActionDispatch::IntegrationTest
  test "forgot password form renders and submitting sends a working reset link" do
    user = User.create!(email: "forgotpwtest@example.com", name: "Test", password: "CorrectHorse123!", password_confirmation: "CorrectHorse123!")
    user.confirm

    get new_user_password_path
    assert_response :success

    assert_emails 1 do
      post user_password_path, params: {email: user.email}
    end
    assert_redirected_to done_password_path

    mail = ActionMailer::Base.deliveries.last
    assert_equal "Reset password instructions", mail.subject
    assert_match "reset_password_token=", mail.body.encoded
  end

  test "unknown email still redirects to the done page (no user enumeration)" do
    get new_user_password_path
    assert_response :success

    assert_emails 0 do
      post user_password_path, params: {email: "nobody@example.com"}
    end
    assert_redirected_to done_password_path
  end

  # Rack::Attack is production-only (config/initializers/rack_attack.rb) so it
  # has to be force-enabled for this test; the throttled_responder redirect it
  # exercises is the same code path production traffic hits.
  test "4th password-reset request within 5 minutes redirects to the branded already-reset screen, not a raw 429" do
    # Rails.cache is a NullStore in the test env, which silently drops the
    # throttle counters — swap in a real in-memory store so Rack::Attack can
    # count requests, and force-enable it (it's production-only by default).
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.enabled = true

    3.times { post user_password_path, params: {email: "nobody@example.com"} }
    post user_password_path, params: {email: "nobody@example.com"}

    assert_redirected_to password_error_already_reset_path
  ensure
    Rack::Attack.enabled = false
    Rack::Attack.cache.store = Rails.cache
  end
end
