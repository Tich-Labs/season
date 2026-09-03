require "rails_helper"

# Multi-day events used to render as a separate, fully-rounded pill
# repeated on every day they cover, reading as disconnected labels rather
# than one continuous appointment (see app/views/calendar/_day_cell.html.erb).
RSpec.describe "Calendar multi-day event bars", type: :request do
  let(:user) { create(:user, :onboarded, last_period_start: 10.days.ago.to_date) }

  before { post session_path, params: {email: user.email, password: "password123"} }

  it "renders a continuous, seam-squared bar across the days a multi-day event spans" do
    start_date = Date.new(2026, 9, 4)
    user.calendar_events.create!(title: "Testing", date: start_date, end_date: start_date + 1,
      start_time: "09:00", end_time: "17:00", category: "Work")

    get calendar_path(date: start_date.to_s)
    expect(response).to have_http_status(:success)

    # Start day: rounded on the outer (left) corners only, squared where it
    # meets tomorrow's segment, bled right by the cell's own padding so the
    # two segments touch with no gap. Label visible.
    expect(response.body).to match(/border-radius:2px 0px 0px 2px; margin:0 -4px 0 0;[^"]*"[^>]*>\s*<span[^>]*>Testing/)
    # Continuation day: squared where it meets yesterday's segment, rounded
    # on the outer (right) end, bled left to close the seam. No repeated label.
    expect(response.body).to include("border-radius:0px 2px 2px 0px; margin:0 0 0 -4px")
  end

  it "leaves a single-day event's pill fully rounded, as before" do
    date = Date.new(2026, 9, 4)
    user.calendar_events.create!(title: "Team sync", date: date,
      start_time: "09:00", end_time: "10:00", category: "Work")

    get calendar_path(date: date.to_s)
    expect(response.body).to match(/border-radius:2px 2px 2px 2px;[^"]*"[^>]*>\s*<span[^>]*>Team sync/)
  end
end
