require "rails_helper"

RSpec.describe GoogleCalendarPushJob, type: :job do
  let(:connected_user) do
    create(:user, :onboarded,
      google_access_token: "access-token",
      google_refresh_token: "refresh-token",
      google_token_expires_at: 1.hour.from_now)
  end
  let(:unconnected_user) { create(:user, :onboarded) }

  let(:google_event) { instance_double(Google::Apis::CalendarV3::Event, id: "google-evt-123") }
  let(:service) { instance_double(GoogleCalendarService) }

  before do
    allow(GoogleCalendarService).to receive(:new).and_return(service)
  end

  describe "create" do
    it "creates the event on Google and stores the returned id" do
      event = create(:calendar_event, user: connected_user, title: "Dentist", google_event_id: nil)
      allow(service).to receive(:create_event).and_return(google_event)

      described_class.perform_now(:create, user_id: connected_user.id, calendar_event_id: event.id)

      expect(service).to have_received(:create_event).with(
        summary: "Dentist", start_time: event.starts_at, end_time: event.ends_at, description: event.notes, location: event.location
      )
      expect(event.reload.google_event_id).to eq("google-evt-123")
    end

    it "does nothing for a user who hasn't connected Google Calendar" do
      event = create(:calendar_event, user: unconnected_user, google_event_id: nil)

      described_class.perform_now(:create, user_id: unconnected_user.id, calendar_event_id: event.id)

      expect(GoogleCalendarService).not_to have_received(:new)
    end

    it "does not re-create an event that already has a google_event_id" do
      event = create(:calendar_event, user: connected_user, google_event_id: "already-there")
      allow(service).to receive(:create_event)

      described_class.perform_now(:create, user_id: connected_user.id, calendar_event_id: event.id)

      expect(service).not_to have_received(:create_event)
    end
  end

  describe "update" do
    it "pushes an update for an event that already has a google_event_id" do
      event = create(:calendar_event, user: connected_user, title: "Dentist", google_event_id: "existing-id")
      allow(service).to receive(:update_event)

      described_class.perform_now(:update, user_id: connected_user.id, calendar_event_id: event.id)

      expect(service).to have_received(:update_event).with(
        "existing-id", summary: "Dentist", start_time: event.starts_at, end_time: event.ends_at, description: event.notes, location: event.location
      )
    end

    it "creates it instead when editing an event never pushed before" do
      event = create(:calendar_event, user: connected_user, google_event_id: nil)
      allow(service).to receive(:create_event).and_return(google_event)

      described_class.perform_now(:update, user_id: connected_user.id, calendar_event_id: event.id)

      expect(service).to have_received(:create_event)
      expect(event.reload.google_event_id).to eq("google-evt-123")
    end
  end

  describe "delete" do
    it "deletes the Google-side event by id" do
      allow(service).to receive(:delete_event)

      described_class.perform_now(:delete, user_id: connected_user.id, google_event_id: "gone-id")

      expect(service).to have_received(:delete_event).with("gone-id")
    end

    it "does nothing when there's no google_event_id (never pushed)" do
      allow(service).to receive(:delete_event)

      described_class.perform_now(:delete, user_id: connected_user.id, google_event_id: nil)

      expect(service).not_to have_received(:delete_event)
    end
  end

  it "swallows a Google-side failure instead of raising back into the job runner" do
    event = create(:calendar_event, user: connected_user, google_event_id: nil)
    allow(service).to receive(:create_event).and_raise(Faraday::SSLError.new("cert verify failed"))

    expect {
      described_class.perform_now(:create, user_id: connected_user.id, calendar_event_id: event.id)
    }.not_to raise_error
  end
end
