# frozen_string_literal: true

RSpec.describe "Settings", type: :feature do
  let(:user) { create(:user, :onboarded, password: "password123") }

  it "navigates between settings sections" do
    sign_in user
    visit "/settings/edit"

    click_link "Profile"
    expect(page).to have_current_path("/settings/profile")

    click_link "Notifications"
    expect(page).to have_current_path("/settings/notifications")
  end
end
