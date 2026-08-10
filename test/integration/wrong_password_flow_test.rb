require "test_helper"

class WrongPasswordFlowTest < ActionDispatch::IntegrationTest
  test "wrong password shows inline error on the login screen" do
    user = User.create!(email: "wrongpwtest@example.com", name: "Test", password: "CorrectHorse123!", password_confirmation: "CorrectHorse123!")
    user.confirm

    post session_path, params: {email: user.email, password: "definitely-wrong"}

    assert_response :unprocessable_content
    assert_match "Wrong E-mail or password", response.body
  end

  test "unknown email shows inline error on the login screen" do
    post session_path, params: {email: "nobody@example.com", password: "whatever"}

    assert_response :unprocessable_content
    assert_match "Wrong E-mail or password", response.body
  end
end
