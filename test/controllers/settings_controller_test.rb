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

  # Removed — not in Figma. Access code lives only on My Profile now, which
  # is /settings/pin's sole entry point, so its hardcoded back link is correct.
  test "GET /settings/edit has no App Lock row" do
    get edit_settings_path
    assert_no_match(/App Lock/, response.body)
    assert_no_match(%r{href="/settings/pin"}, response.body)
  end

  test "GET /settings/consent returns 200 and its back link goes to the settings menu" do
    get "/settings/consent"
    assert_response :success
    # Its only real entry point is /settings/edit — the back link used to be
    # hardcoded to user_root_path (calendar), skipping past the settings menu
    # entirely instead of returning to where the user actually came from.
    assert_match %r{href="/settings/edit"}, response.body
  end

  test "GET /settings/profile returns 200" do
    get profile_settings_path
    assert_response :success
  end

  # /settings/profile has two real entry points — the main settings menu and
  # the avatar on /tracking — so its back link must reflect the actual
  # referer instead of assuming one fixed parent.
  test "GET /settings/profile back link reflects the settings menu as referer" do
    get profile_settings_path, headers: {"HTTP_REFERER" => edit_settings_url}
    assert_match %r{href="/settings/edit"}, response.body
  end

  test "GET /settings/profile back link reflects tracking as referer" do
    get profile_settings_path, headers: {"HTTP_REFERER" => tracking_index_url}
    assert_match %r{href="/tracking"}, response.body
  end

  test "GET /settings/profile back link falls back to settings menu with no referer" do
    get profile_settings_path
    assert_match %r{href="/settings/edit"}, response.body
  end

  test "GET /settings/profile back link ignores an off-site referer" do
    get profile_settings_path, headers: {"HTTP_REFERER" => "https://evil.example.com/phishing"}
    assert_match %r{href="/settings/edit"}, response.body
    assert_no_match(/evil\.example\.com/, response.body)
  end

  # Regression for a real reported bug: this used to trust *any* same-origin
  # referer. /account's back link also resolves dynamically from its own
  # referer, so leaving /account back to here made /account the referer for
  # this load -- pointing this page's back link at /account and ping-ponging
  # the two pages forever. /account isn't one of this page's two real entry
  # points (settings menu, or the avatar on /tracking), so it must be
  # ignored even though it's same-origin.
  test "GET /settings/profile back link ignores /account as an untrusted referer" do
    get profile_settings_path, headers: {"HTTP_REFERER" => account_url}
    # This page also has its own unrelated "Delete Account" row linking to
    # /account, so check the header's back link specifically, not just
    # absence of "/account" anywhere on the page.
    assert_select "header a[href='/settings/edit']"
    assert_select "header a[href='/account']", false
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

  test "PATCH /settings/calendar saves show_tracked_days" do
    patch update_calendar_settings_path, params: {show_tracked_days: "0"}
    assert_redirected_to calendar_settings_path
    assert_equal false, @alice.reload.show_tracked_days
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

  test "GET /settings/pin shows the no-access-code privacy warning when unset" do
    assert_not @alice.pin_set?
    get pin_settings_path
    assert_match(/haven't set an access code/, CGI.unescapeHTML(response.body))
  end

  test "GET /settings/pin hides the privacy warning once a pin is set" do
    @alice.set_pin("1234")
    get pin_settings_path
    assert_no_match(/haven't set an access code/, CGI.unescapeHTML(response.body))
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

  test "PATCH /settings/update_notifications saves a reminder-backed toggle" do
    patch update_notifications_settings_path, params: {cycle_reminder: "1"}, as: :json
    assert_response :success
    reminder = @alice.reminders.find_by(reminder_type: "morning")
    assert reminder.active?
  end

  test "PATCH /settings/update_notifications saves a preference-only toggle" do
    patch update_notifications_settings_path, params: {push_new_appt_synced: "0"}, as: :json
    assert_response :success
    assert_equal false, @alice.reload.notification_preferences["push_new_appt_synced"]
  end

  # Regression test: reminder_type "in_app" (mapped from the email_notifications
  # key) wasn't in Reminder::TYPES, so this request 500'd via an unrescued
  # ActiveRecord::RecordInvalid from reminder.save! — see app/models/reminder.rb.
  test "PATCH /settings/update_notifications saves the in-app popups toggle" do
    patch update_notifications_settings_path, params: {email_notifications: "1"}, as: :json
    assert_response :success
    reminder = @alice.reminders.find_by(reminder_type: "in_app")
    assert reminder.active?
  end

  # M1 — Settings screens should show only the centred calendar FAB
  # (bg-brand-field, aria-label "Go to calendar"), not the "+" quick-actions
  # FAB or the default bottom-right calendar FAB (aria-label
  # "Back to calendar") — supersedes the earlier "+"-only requirement.
  test "GET /settings/profile shows only the centred calendar FAB" do
    get profile_settings_path
    assert_response :success
    assert_no_match(/quick-actions#open/, response.body)
    assert_no_match(/Back to calendar/, response.body)
    assert_match(/Go to calendar/, response.body)
  end
end
