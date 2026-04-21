# frozen_string_literal: true

RSpec.describe "Symptom Tracking", type: :feature do
  let(:user) { create(:user, :onboarded, password: "password123") }

  it "logs period start" do
    sign_in user
    visit "/tracking"

    check "Period started today"
    click_button "Save"

    expect(user.reload.last_period_start).to eq(Time.zone.today)
  end
end
