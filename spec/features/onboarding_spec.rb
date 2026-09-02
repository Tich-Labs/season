# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Onboarding", type: :feature do
  let(:user) { create(:user, password: "password123") }

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

  it "skips optional steps" do
    login_as(user)
    visit "/onboarding/8"

    # There's no button literally labeled "Skip" on this step — "None" is
    # the first birth-control-method option and is what actually lets you
    # move on without answering (step 8 isn't in
    # User::REQUIRED_ONBOARDING_STEPS, so it's optional either way).
    click_button "None"
    expect(page).to have_current_path("/onboarding/9")
  end
end
