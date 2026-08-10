require "test_helper"

class ChangePasswordFlowTest < ActionDispatch::IntegrationTest
  def onboarded_user(email:)
    User.create!(
      email: email, name: "Test", password: "OldPass123!", password_confirmation: "OldPass123!",
      birthday: 30.years.ago, has_regular_cycle: true, uses_hormonal_birth_control: false,
      food_preference: "omnivore", onboarding_completed: true
    ).tap(&:confirm)
  end

  test "changing password with correct current password works and is confirmed via flash" do
    user = onboarded_user(email: "changepwtest@example.com")
    post session_path, params: {email: user.email, password: "OldPass123!"}

    patch update_password_settings_path, params: {
      current_password: "OldPass123!",
      password: "NewPass456!",
      password_confirmation: "NewPass456!"
    }
    assert_redirected_to profile_settings_path
    assert_equal "Password updated.", flash[:notice]

    follow_redirect!
    assert_match "Password updated.", response.body
    assert user.reload.valid_password?("NewPass456!"), "password was not actually updated"
  end

  test "changing password with wrong current password fails and shows an error" do
    user = onboarded_user(email: "changepwtest2@example.com")
    post session_path, params: {email: user.email, password: "OldPass123!"}

    patch update_password_settings_path, params: {
      current_password: "totally-wrong",
      password: "NewPass456!",
      password_confirmation: "NewPass456!"
    }
    assert_redirected_to profile_settings_path
    assert_equal "Current password is incorrect.", flash[:alert]

    follow_redirect!
    assert_match "Current password is incorrect.", response.body
    assert_not user.reload.valid_password?("NewPass456!")
    assert user.valid_password?("OldPass123!")
  end
end
