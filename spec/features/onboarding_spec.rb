# frozen_string_literal: true

RSpec.describe "Onboarding", type: :feature do
  let(:user) { create(:user, password: "password123") }

  it "skips optional steps" do
    sign_in user
    visit "/onboarding/8"

    click_button "Skip"
    expect(page).to have_current_path("/onboarding/9")
  end
end
