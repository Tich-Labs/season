require "rails_helper"

# Confirmed live via a user report: Medical and Birthday appointments on
# the Schedule overview page (calendar/appointments) both showed the same
# generic default icon instead of their real category icon. Root cause: a
# prior fix (commit 7fdedfc) for a File.read-in-production bug replaced
# the real category_icon_map (Friends/Dinner/Date/Sport/Medical/Birthday/
# Work/Coffee/Shopping) with a fuzzy keyword-guessing regex that only
# coincidentally matched 3 of the 9 real category values (Sport, Date,
# Dinner) -- Medical, Birthday, Friends, Work, Coffee, and Shopping all
# silently fell through to the same default icon.
RSpec.describe "Schedule overview category icons", type: :request do
  let(:user) { create(:user, :onboarded) }
  let(:date) { Date.new(2026, 9, 10) }

  before { post session_path, params: {email: user.email, password: "password123"} }

  it "renders the real, distinct icon asset for each category, not a keyword-guessed fallback" do
    %w[Medical Birthday Friends Shopping].each do |category|
      user.calendar_events.create!(title: "#{category} test", date: date, start_time: "10:00", end_time: "11:00", category: category)
    end

    get calendar_appointments_path(date: date.to_s)
    expect(response).to have_http_status(:success)

    # asset_path digests the filename (e.g. medical-0109cc68.svg), so match
    # the stem rather than an exact filename.
    %w[medical birthday family shopping].each do |icon_stem|
      expect(response.body).to match(%r{icons/appointment/#{icon_stem}(-\w+)?\.svg})
    end
  end
end
