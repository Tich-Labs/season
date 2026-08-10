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
end
