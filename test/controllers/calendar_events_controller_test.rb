require "test_helper"

# M4 — Calendar Events / Appointments
class CalendarEventsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
    sign_in_as(@alice)
    @event = calendar_events(:alice_appointment)
  end

  test "GET /calendar_events/new returns 200" do
    get new_calendar_event_path
    assert_response :success
  end

  test "GET /calendar_events/new requires authentication" do
    delete session_path
    get new_calendar_event_path
    assert_redirected_to new_session_path
  end

  test "POST /calendar_events creates an event and redirects to calendar" do
    assert_difference("CalendarEvent.count", 1) do
      post calendar_events_path, params: {
        calendar_event: {
          title: "Dentist",
          date: 5.days.from_now.to_date.to_s,
          category: "appointment"
        }
      }
    end
    assert_redirected_to calendar_path
  end

  test "POST /calendar_events with blank title renders 422" do
    post calendar_events_path, params: {
      calendar_event: {title: "", date: Time.zone.today.to_s}
    }
    assert_response :unprocessable_entity
  end

  test "GET /calendar_events/:id/edit returns 200" do
    get edit_calendar_event_path(@event)
    assert_response :success
  end

  test "PATCH /calendar_events/:id updates the event" do
    patch calendar_event_path(@event), params: {
      calendar_event: {title: "Updated title", date: @event.date.to_s}
    }
    assert_redirected_to calendar_path
    assert_equal "Updated title", @event.reload.title
  end

  test "DELETE /calendar_events/:id removes the event" do
    assert_difference("CalendarEvent.count", -1) do
      delete calendar_event_path(@event)
    end
    assert_redirected_to calendar_path
  end

  test "cannot edit another user's event" do
    bob_event = users(:bob).calendar_events.create!(title: "Bob's event", date: Time.zone.today)
    get edit_calendar_event_path(bob_event)
    assert_response :not_found
  end
end
