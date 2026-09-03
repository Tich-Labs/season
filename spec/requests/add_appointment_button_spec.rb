require "rails_helper"

# "+" button that lets a user add another appointment for a date that
# already has one, without leaving the page — added to both places that
# list existing appointments for a date.
RSpec.describe "Add-another-appointment button", type: :request do
  let(:user) { create(:user, :onboarded, last_period_start: 10.days.ago.to_date) }
  let(:date) { Date.new(2026, 9, 5) }

  before do
    user.calendar_events.create!(title: "Testing", date: date, start_time: "10:00", end_time: "11:00", category: "Date")
    post session_path, params: {email: user.email, password: "password123"}
  end

  it "appears on the forecast page and links to /new with the same date" do
    get forecast_path(date: date.to_s)
    expect(response.body).to include(new_calendar_event_path(date: date))
  end

  it "appears on the schedule overview page and links to /new with that date" do
    get calendar_appointments_path(date: date.to_s)
    expect(response.body).to include(new_calendar_event_path(date: date))
  end
end
