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

  test "GET /settings/pin returns 200" do
    get pin_settings_path
    assert_response :success
  end

  test "POST /settings/pin sets pin" do
    assert_not @alice.pin_set?
    post pin_settings_path, params: {pin: "1234", pin_confirmation: "1234"}
    assert_redirected_to profile_settings_path
    assert @alice.reload.pin_set?
  end

  test "POST /settings/pin rejects mismatch" do
    post pin_settings_path, params: {pin: "1234", pin_confirmation: "5678"}
    assert_redirected_to pin_settings_path
    assert_not @alice.reload.pin_set?
  end

  test "DELETE /settings/pin removes pin" do
    @alice.set_pin("1234")
    delete pin_settings_path, params: {pin: "1234"}
    assert_redirected_to profile_settings_path
    assert_not @alice.reload.pin_set?
  end

  test "DELETE /settings/pin with wrong pin does not remove" do
    @alice.set_pin("1234")
    delete pin_settings_path, params: {pin: "9999"}
    assert_redirected_to profile_settings_path
    assert @alice.reload.pin_set?
  end

  test "settings edit page shows unlock modal when PIN is set" do
    @alice.set_pin("1234")
    get edit_settings_path
    assert_response :success
    assert_includes response.body, "pin-unlock-modal"
  end
end
