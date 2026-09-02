require "rails_helper"

# Converted from spec/features/symptom_tracking_spec.rb, which drove a
# "Period started today" checkbox that doesn't exist in the current UI —
# /tracking/period is a calendar date-picker now (click a day cell, submit
# via Turbo/JS), not a checkbox. That interaction isn't reliably
# simulable with the no-JS rack_test Capybara driver this app's other
# feature specs use, so this tests the real PATCH endpoint directly
# instead — TrackingController#period_update expects `last_period_start`/
# `last_period_end` as top-level date params, not nested under a model key.
RSpec.describe "Tracking period", type: :request do
  let(:user) { create(:user, :onboarded) }

  before { post session_path, params: {email: user.email, password: "password123"} }

  it "logs period start for today" do
    patch period_tracking_index_path, params: {last_period_start: Time.zone.today.iso8601}

    expect(response).to redirect_to(tracking_index_path(tracking_saved: 1))
    expect(user.reload.last_period_start).to eq(Time.zone.today)
  end
end
