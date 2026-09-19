require "rails_helper"

RSpec.describe "Settings iCloud Calendar", type: :request do
  let(:user) { create(:user, :onboarded) }

  before { post session_path, params: {email: user.email, password: "password123"} }

  describe "POST /settings/connect_icloud_calendar" do
    it "saves the credentials and redirects with a success notice when they verify" do
      allow(IcloudCalendarService).to receive(:verify_credentials!).and_return(true)

      post connect_icloud_calendar_settings_path, params: {icloud_email: "me@icloud.com", icloud_app_password: "abcd-efgh-ijkl-mnop"}

      expect(response).to redirect_to(calendar_settings_path)
      expect(user.reload.icloud_email).to eq("me@icloud.com")
      expect(user.icloud_app_password).to eq("abcd-efgh-ijkl-mnop")
    end

    it "does not save anything and shows an alert when verification fails" do
      allow(IcloudCalendarService).to receive(:verify_credentials!).and_raise(IcloudCalendarService::AuthenticationError)

      post connect_icloud_calendar_settings_path, params: {icloud_email: "me@icloud.com", icloud_app_password: "wrong"}

      expect(response).to redirect_to(calendar_settings_path)
      follow_redirect!
      expect(response.body).to include(I18n.t("settings.calendar.icloud_failed", default: "Connection failed — check your Apple ID and app-specific password"))
      expect(user.reload.icloud_email).to be_nil
    end
  end

  describe "POST /settings/disconnect_icloud_calendar" do
    it "clears the stored credentials" do
      user.update!(icloud_email: "me@icloud.com", icloud_app_password: "abcd-efgh-ijkl-mnop")

      post disconnect_icloud_calendar_settings_path

      expect(user.reload.icloud_email).to be_nil
      expect(user.icloud_app_password).to be_nil
    end
  end

  describe "POST /settings/sync_icloud_calendar" do
    it "imports new events, skipping ones already synced" do
      user.update!(icloud_email: "me@icloud.com", icloud_app_password: "abcd-efgh-ijkl-mnop")
      create(:calendar_event, user: user, icloud_event_id: "already-synced")

      events = [
        IcloudCalendarService::Event.new(uid: "already-synced", summary: "Old", starts_at: 1.day.from_now, ends_at: 1.day.from_now + 1.hour),
        IcloudCalendarService::Event.new(uid: "new-event", summary: "Team sync", starts_at: 2.days.from_now, ends_at: 2.days.from_now + 1.hour, location: "Zoom")
      ]
      icloud_service = instance_double(IcloudCalendarService, list_events: events)
      allow(IcloudCalendarService).to receive(:new).and_return(icloud_service)

      expect {
        post sync_icloud_calendar_settings_path
      }.to change(CalendarEvent, :count).by(1)

      imported = CalendarEvent.find_by(icloud_event_id: "new-event")
      expect(imported.title).to eq("Team sync")
      expect(imported.location).to eq("Zoom")
    end
  end
end
