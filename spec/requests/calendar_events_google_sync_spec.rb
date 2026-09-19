require "rails_helper"

# The "push" half of Google Calendar sync -- CalendarEventsController
# enqueues GoogleCalendarPushJob on create/update/destroy, but only for
# users who've actually connected Google Calendar. See
# GoogleCalendarPushJob for the job itself, and
# SettingsController#sync_google_calendar for the "pull" half.
RSpec.describe "CalendarEvents Google Calendar push", type: :request do
  let(:connected_user) do
    create(:user, :onboarded,
      google_access_token: "access-token",
      google_refresh_token: "refresh-token",
      google_token_expires_at: 1.hour.from_now)
  end
  let(:unconnected_user) { create(:user, :onboarded) }

  def login_as(user)
    post session_path, params: {email: user.email, password: "password123"}
  end

  describe "a user with Google Calendar connected" do
    before { login_as(connected_user) }

    it "enqueues a create push when a new appointment is saved" do
      expect {
        post calendar_events_path, params: {
          calendar_event: {title: "Yoga", date: Time.zone.tomorrow, start_time: "09:00", end_time: "10:00"}
        }
      }.to have_enqueued_job(GoogleCalendarPushJob).with(:create, user_id: connected_user.id, calendar_event_id: kind_of(Integer), google_event_id: nil)
    end

    it "enqueues an update push when an appointment is edited" do
      event = create(:calendar_event, user: connected_user)

      expect {
        patch calendar_event_path(event), params: {calendar_event: {title: "Rescheduled"}}
      }.to have_enqueued_job(GoogleCalendarPushJob).with(:update, user_id: connected_user.id, calendar_event_id: event.id, google_event_id: nil)
    end

    it "enqueues a delete push (with the Google event id) when an appointment is deleted" do
      event = create(:calendar_event, user: connected_user, google_event_id: "google-evt-1")

      expect {
        delete calendar_event_path(event)
      }.to have_enqueued_job(GoogleCalendarPushJob).with(:delete, user_id: connected_user.id, calendar_event_id: nil, google_event_id: "google-evt-1")
    end

    it "does not enqueue a delete push for an appointment that was never synced" do
      event = create(:calendar_event, user: connected_user, google_event_id: nil)

      expect {
        delete calendar_event_path(event)
      }.not_to have_enqueued_job(GoogleCalendarPushJob)
    end
  end

  describe "a user without Google Calendar connected" do
    before { login_as(unconnected_user) }

    it "does not enqueue anything on create/update/destroy" do
      expect {
        post calendar_events_path, params: {
          calendar_event: {title: "Yoga", date: Time.zone.tomorrow, start_time: "09:00", end_time: "10:00"}
        }
      }.not_to have_enqueued_job(GoogleCalendarPushJob)

      event = create(:calendar_event, user: unconnected_user)

      expect {
        patch calendar_event_path(event), params: {calendar_event: {title: "Rescheduled"}}
      }.not_to have_enqueued_job(GoogleCalendarPushJob)

      expect {
        delete calendar_event_path(event)
      }.not_to have_enqueued_job(GoogleCalendarPushJob)
    end
  end
end
