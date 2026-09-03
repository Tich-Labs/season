require "rails_helper"

# New appointments used to default to tomorrow's date. Backdating an
# appointment is the rare case; logging something happening today is the
# common one, so the default should be today (now), not tomorrow.
RSpec.describe "New appointment form defaults", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user, :onboarded) }

  before { post session_path, params: {email: user.email, password: "password123"} }

  it "defaults to today's date (not tomorrow) when no date param is given" do
    travel_to Time.zone.local(2026, 9, 3, 12, 6) do
      get new_calendar_event_path
      expect(response.body).to include(Time.zone.today.strftime("%a. %b ") + Time.zone.today.day.ordinalize)
    end
  end

  it "rounds the default start time up to the picker's 5-minute granularity, from now" do
    travel_to Time.zone.local(2026, 9, 3, 12, 6) do
      get new_calendar_event_path
      expect(response.body).to include('data-appointment-date-picker-target="startField" value="12:10"')
      expect(response.body).to include('data-appointment-date-picker-target="endField" value="13:10"')
    end
  end

  it "still honours an explicit ?date= param over today's default" do
    future = Time.zone.today + 10
    get new_calendar_event_path(date: future.to_s)
    expect(response.body).to include(future.strftime("%a. %b ") + future.day.ordinalize)
  end
end
