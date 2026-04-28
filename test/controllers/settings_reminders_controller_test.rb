require "test_helper"

class SettingsRemindersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
    sign_in_as(@alice)
  end

  # --- Morning reminder ---

  test "PATCH save_morning_reminder creates reminder when none exists" do
    Reminder.where(user: @alice, reminder_type: "morning").delete_all
    patch save_morning_reminder_settings_path, params: {enabled: "1", time: "08:00"}
    reminder = @alice.reminders.find_by(reminder_type: "morning")
    assert_not_nil reminder
    assert reminder.active?
    assert_equal "08:00", reminder.time.strftime("%H:%M")
  end

  test "PATCH save_morning_reminder updates existing reminder" do
    reminders(:alice_morning).update!(active: true, time: "09:00")
    patch save_morning_reminder_settings_path, params: {enabled: "0", time: "07:30"}
    reminders(:alice_morning).reload
    assert_not reminders(:alice_morning).active?
  end

  test "PATCH save_morning_reminder redirects back to notification_morning" do
    patch save_morning_reminder_settings_path, params: {enabled: "1", time: "09:00"}
    assert_redirected_to notification_morning_settings_path
  end

  test "GET notification_morning requires authentication" do
    delete session_path
    get notification_morning_settings_path
    assert_redirected_to new_session_path
  end

  # --- Period reminder ---

  test "PATCH save_period_reminder creates period_start and period_end records" do
    Reminder.where(user: @alice, reminder_type: %w[period_start period_end]).delete_all
    patch save_period_reminder_settings_path, params: {
      enabled: "1",
      period_start_time: "08:00",
      period_end_time: "09:00",
      advance_days: "3"
    }
    start_r = @alice.reminders.find_by(reminder_type: "period_start")
    end_r = @alice.reminders.find_by(reminder_type: "period_end")
    assert start_r.active?
    assert end_r.active?
    assert_equal 3, start_r.advance_days
  end

  test "PATCH save_period_reminder redirects back to notification_period" do
    patch save_period_reminder_settings_path, params: {
      enabled: "1", period_start_time: "08:00", period_end_time: "09:00", advance_days: "2"
    }
    assert_redirected_to notification_period_settings_path
  end

  # --- Birth control reminder ---

  test "PATCH save_birth_control_reminder creates pill reminder" do
    Reminder.where(user: @alice, reminder_type: "pill").delete_all
    patch save_birth_control_reminder_settings_path, params: {enabled: "1", time: "21:00"}
    reminder = @alice.reminders.find_by(reminder_type: "pill")
    assert_not_nil reminder
    assert reminder.active?
    assert_equal "21:00", reminder.time.strftime("%H:%M")
  end

  test "PATCH save_birth_control_reminder can disable reminder" do
    reminders(:alice_pill).update!(active: true)
    patch save_birth_control_reminder_settings_path, params: {enabled: "0", time: "21:00"}
    reminders(:alice_pill).reload
    assert_not reminders(:alice_pill).active?
  end

  test "PATCH save_birth_control_reminder redirects back to notification_birth_control" do
    patch save_birth_control_reminder_settings_path, params: {enabled: "1", time: "21:00"}
    assert_redirected_to notification_birth_control_settings_path
  end
end
