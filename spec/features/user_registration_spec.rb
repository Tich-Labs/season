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

    expect(page).to have_current_path("/onboarding/1")
  end
end
