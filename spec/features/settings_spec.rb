# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Settings", type: :feature do
  let(:user) { create(:user, :onboarded, password: "password123") }

  # See spec/features/calendar_spec.rb for why this drives the real login
  # form instead of Devise::Test's `sign_in` or rack-test's
  # `set_rack_session` (neither works against this app's own
  # session[:user_id]-based auth).
  def login_as(user, password: "password123")
    visit new_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: password
    click_button "Log In"
  end

  it "navigates to settings sections from the hub" do
    login_as(user)

    # /settings/profile isn't itself a hub with a nav back out to sibling
    # sections (no "Notifications" link on it) — each section is reached
    # from /settings/edit, not chained from one sub-page to the next.
    visit "/settings/edit"
    click_link "Profile"
    expect(page).to have_current_path("/settings/profile")

    visit "/settings/edit"
    click_link "Notifications"
    expect(page).to have_current_path("/settings/notifications")
  end
end
