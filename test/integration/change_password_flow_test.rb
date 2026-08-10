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

  test "changing password with mismatched confirmation fails and shows an error" do
    user = onboarded_user(email: "changepwtest3@example.com")
    post session_path, params: {email: user.email, password: "OldPass123!"}

    patch update_password_settings_path, params: {
      current_password: "OldPass123!",
      password: "NewPass456!",
      password_confirmation: "SomethingElse789!"
    }
    assert_redirected_to profile_settings_path
    assert_match(/doesn't match|does not match/i, flash[:alert].to_s)

    assert_not user.reload.valid_password?("NewPass456!")
    assert user.valid_password?("OldPass123!"), "old password should still work since the update was rejected"
  end

  test "changing password to something too short fails and shows an error" do
    user = onboarded_user(email: "changepwtest4@example.com")
    post session_path, params: {email: user.email, password: "OldPass123!"}

    patch update_password_settings_path, params: {
      current_password: "OldPass123!",
      password: "abc",
      password_confirmation: "abc"
    }
    assert_redirected_to profile_settings_path
    assert flash[:alert].present?

    assert_not user.reload.valid_password?("abc")
    assert user.valid_password?("OldPass123!"), "old password should still work since the update was rejected"
  end
end
