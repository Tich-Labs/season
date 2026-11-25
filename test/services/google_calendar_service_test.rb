require "test_helper"

class GoogleCalendarServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:alice)
    @user.update!(
      google_access_token: "stale-token",
      google_refresh_token: "refresh-token",
      google_token_expires_at: 1.hour.from_now,
      google_calendar_email: "alice@example.com",
      calendar_sync_level: "two_way"
    )
  end

  test "list_events clears invalid tokens when Signet raises an authorization error" do
    assert_nil list_events_raising(Google::Auth::AuthorizationError)

    @user.reload
    assert_nil @user.google_access_token
    assert_nil @user.google_refresh_token
    assert_nil @user.google_token_expires_at
    assert_nil @user.google_calendar_email
    assert_equal "off", @user.calendar_sync_level
  end

  test "list_events clears invalid tokens when the API raises an authorization error" do
    assert_nil list_events_raising(Google::Apis::AuthorizationError)

    assert_nil @user.reload.google_access_token
    assert_equal "off", @user.calendar_sync_level
  end

  private

  def list_events_raising(error_class)
    api = Google::Apis::CalendarV3::CalendarService.new
    api.define_singleton_method(:list_events) { |*| raise error_class, "invalid_grant" }

    stub_class_method(Google::Apis::CalendarV3::CalendarService, :new, -> { api }) do
      GoogleCalendarService.new(@user).list_events
    end
  end
end
