# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User Registration", type: :feature do
  it "signs up successfully" do
    visit "/registration/new"

    fill_in "email", with: "test#{Time.now.to_i}@example.com"
    fill_in "password_field", with: "password123"
    fill_in "password_confirmation_field", with: "password123"
    check "terms_accepted"

    click_button "Create account"

    # Not /onboarding/1 — signup redirects to the "check your inbox" page
    # first (Devise :confirmable); /onboarding/1 is only reached after
    # confirming via the emailed link (see ConfirmationsController#show).
    expect(page).to have_current_path("/registration/check_email")
  end
end
