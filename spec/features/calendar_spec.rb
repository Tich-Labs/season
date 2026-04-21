# frozen_string_literal: true

RSpec.describe "Calendar Navigation", type: :feature do
  let(:user) { create(:user, :onboarded, password: "password123") }

  it "displays the monthly calendar" do
    sign_in user
    visit "/"

    expect(page).to have_content("Calendar")
  end

  it "switches to weekly view" do
    sign_in user
    visit "/"
    click_link "Week"

    expect(page).to have_current_path("/calendar/weekly")
  end

  it "views specific day" do
    sign_in user
    visit "/"

    click_link Time.zone.today.day.to_s
    expect(page).to have_current_path("/daily/#{Time.zone.today}")
  end
end
