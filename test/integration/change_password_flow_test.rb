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
    assert_equal "Current password is wrong, please try again", flash[:password_modal_error]
    assert_nil flash[:alert], "should not also duplicate into the top flash banner"

    follow_redirect!
    assert_match "Current password is wrong, please try again", response.body
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
    assert_equal "New passwords are not identical, please try again", flash[:password_modal_error]

    follow_redirect!
    assert_match "New passwords are not identical, please try again", response.body
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
    assert flash[:password_modal_error].present?

    assert_not user.reload.valid_password?("abc")
    assert user.valid_password?("OldPass123!"), "old password should still work since the update was rejected"
  end

  test "a failed password change reopens the modal with the inline error visible" do
    user = onboarded_user(email: "changepwtest5@example.com")
    post session_path, params: {email: user.email, password: "OldPass123!"}

    patch update_password_settings_path, params: {
      current_password: "totally-wrong",
      password: "NewPass456!",
      password_confirmation: "NewPass456!"
    }
    follow_redirect!

    assert_select "#password-modal.flex"
    assert_select "#password-modal[role=dialog]" do
      assert_select "[role=alert]", text: "Current password is wrong, please try again"
    end
  end
end
