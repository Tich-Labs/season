require "rails_helper"

# Regression coverage for a real bug found 19 Sep 2026: create_event/
# update_event passed start_time/end_time straight through to
# Google::Apis::CalendarV3::EventDateTime#date_time. Handed an
# ActiveSupport::TimeWithZone (what CalendarEvent#starts_at/#ends_at
# return) or a plain Time, google-apis-calendar_v3's representer doesn't
# know how to render it as RFC3339 and silently falls back to Ruby's
# default #to_s ("2026-09-19 14:00:15 UTC") -- which Google Calendar
# rejects with an opaque, field-less "400 Bad Request". Verified live
# against a real connected account. Only a real DateTime renders
# correctly, hence #to_google_datetime.
RSpec.describe GoogleCalendarService do
  let(:user) do
    create(:user, :onboarded,
      google_access_token: "access-token",
      google_refresh_token: "refresh-token",
      google_token_expires_at: 1.hour.from_now)
  end
  let(:service) { described_class.new(user) }
  let(:api_service) { instance_double(Google::Apis::CalendarV3::CalendarService, client_options: Google::Apis::ClientOptions.new, "authorization=": nil) }
  let(:start_time) { Time.zone.local(2026, 9, 19, 11, 50) }
  let(:end_time) { Time.zone.local(2026, 9, 19, 13, 50) }

  before do
    allow(Google::Apis::CalendarV3::CalendarService).to receive(:new).and_return(api_service)
    allow(user).to receive(:refresh_google_token_if_needed!)
  end

  describe "#create_event" do
    it "sends a real DateTime, not the bare ActiveSupport::TimeWithZone/Time" do
      inserted_event = nil
      allow(api_service).to receive(:insert_event) { |_cal, event| inserted_event = event }

      service.create_event(summary: "Dentist", start_time: start_time, end_time: end_time)

      expect(inserted_event.start.date_time).to be_a(DateTime)
      expect(inserted_event.end.date_time).to be_a(DateTime)
      # The exact regression: a bare Time/TimeWithZone renders as
      # "2026-09-19 11:50:00 UTC" (rejected by Google); DateTime#rfc3339
      # renders the correct wire format.
      expect(inserted_event.start.date_time.rfc3339).to eq(start_time.to_datetime.rfc3339)
    end
  end

  describe "#update_event" do
    it "also normalizes to DateTime" do
      updated_event = nil
      allow(api_service).to receive(:update_event) { |_cal, _id, event| updated_event = event }

      service.update_event("google-evt-1", summary: "Dentist", start_time: start_time, end_time: end_time)

      expect(updated_event.start.date_time).to be_a(DateTime)
      expect(updated_event.end.date_time).to be_a(DateTime)
    end
  end
end
