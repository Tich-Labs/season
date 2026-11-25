require "test_helper"

class GoogleCalendarImportServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:alice)
    @other_user = users(:bob)
  end

  test "imports primary calendar events and ignores duplicates from other users" do
    @other_user.calendar_events.create!(
      google_event_id: "shared-event-id",
      source: "google",
      title: "Other user event",
      date: Date.new(2026, 11, 25)
    )

    events = [
      google_event("shared-event-id", "Dentist", Time.zone.local(2026, 11, 25, 10)),
      google_event("new-event-id", "Therapy", Time.zone.local(2026, 11, 26, 11, 30))
    ]
    service = Object.new
    service.define_singleton_method(:list_events) { |**_kwargs| events }

    stub_class_method(GoogleCalendarService, :new, ->(_user) { service }) do
      assert_equal 2, GoogleCalendarImportService.call(user: @user)
    end

    imported = @user.calendar_events.from_google.order(:google_event_id)
    assert_equal %w[new-event-id shared-event-id], imported.pluck(:google_event_id)
    assert_equal "Dentist", imported.find_by(google_event_id: "shared-event-id").title
    assert_equal "10:00", imported.find_by(google_event_id: "shared-event-id").start_time.strftime("%H:%M")
    assert_equal "11:00", imported.find_by(google_event_id: "shared-event-id").end_time.strftime("%H:%M")
  end

  private

  def google_event(id, summary, starts_at)
    Google::Apis::CalendarV3::Event.new(
      id: id,
      summary: summary,
      start: Google::Apis::CalendarV3::EventDateTime.new(date_time: starts_at),
      end: Google::Apis::CalendarV3::EventDateTime.new(date_time: starts_at + 1.hour)
    )
  end
end
