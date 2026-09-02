# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Calendar Navigation", type: :feature do
  let(:user) { create(:user, :onboarded, password: "password123") }

  # This app's current_user is its own session[:user_id]-based
  # Authentication concern, entirely separate from Devise's Warden session
  # — Devise::Test's `sign_in` sets the Warden session, which current_user
  # never reads, so it silently landed on the logged-out page instead of
  # authenticating. rack-test's `set_rack_session` isn't available in this
  # Capybara/rack-test version either, so this drives the real login form.
  def login_as(user, password: "password123")
    visit new_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: password
    click_button "Log In"
  end

  it "displays the monthly calendar" do
    # Not "/" — that's the public landing/countdown page (see
    # home/countdown.html.erb), not the authenticated calendar. Visiting it
    # after logging in was silently landing back on logged-out content.
    login_as(user)
    visit "/calendar"

    # The page never actually renders the literal word "Calendar" — this
    # is content the monthly grid genuinely shows instead.
    expect(page).to have_content("This is your month")
  end

  it "switches to weekly view" do
    login_as(user)
    visit "/calendar"
    # Both the quick-switcher and the burger menu render a "Weekly-View"
    # link on this page — match: :first, either one navigates the same
    # place.
    click_link "Weekly-View", match: :first

    expect(page).to have_current_path("/calendar/weekly")
  end

  it "views specific day" do
    login_as(user)
    visit "/calendar"

    click_link Time.zone.today.day.to_s, match: :first
    # Not /daily/:date — clicking a calendar day currently routes to the
    # Forecast tab for that date instead (per the recent forecast-redirect
    # work in the app), not the separate /daily/:date screen.
    expect(page).to have_current_path("/forecast?date=#{Time.zone.today}")
  end
end
