require "test_helper"

# M1 + M5 — Settings screens
class SettingsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
    sign_in_as(@alice)
  end

  test "GET /settings/edit returns 200" do
    get edit_settings_path
    assert_response :success
  end

  test "GET /settings/profile returns 200" do
    get profile_settings_path
    assert_response :success
  end

  test "GET /settings/notifications returns 200" do
    get notifications_settings_path
    assert_response :success
  end

  test "GET /settings/notification_morning returns 200" do
    get notification_morning_settings_path
    assert_response :success
  end

  test "GET /settings/notification_period returns 200" do
    get notification_period_settings_path
    assert_response :success
  end

  test "GET /settings/notification_birth_control returns 200" do
    get notification_birth_control_settings_path
    assert_response :success
  end

  test "GET /settings/subscriptions returns 200" do
    get subscriptions_settings_path
    assert_response :success
  end

  test "GET /settings/calendar returns 200" do
    get calendar_settings_path
    assert_response :success
  end

  test "PATCH /settings updates user language" do
    patch settings_path, params: {user: {language: "de"}}
    assert_redirected_to edit_settings_path
    assert_equal "de", @alice.reload.language
  end

  test "PATCH /settings/update_profile updates name" do
    patch update_profile_settings_path, params: {name: "Alice Updated"}
    assert_redirected_to profile_settings_path
    assert_equal "Alice Updated", @alice.reload.name
  end

  test "all settings pages require authentication" do
    delete session_path
    [edit_settings_path, profile_settings_path, notifications_settings_path].each do |path|
      get path
      assert_redirected_to new_session_path, "Expected #{path} to require auth"
    end
  end
end
