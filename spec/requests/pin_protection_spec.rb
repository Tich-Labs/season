require "rails_helper"

# Covers a Trello card: "Code Popup pops up randomly after setting or
# editing appointments". Root cause: session[:pin_verified_at] was written
# once at login/PIN-entry and never refreshed, so PinProtection::PIN_TIMEOUT
# (5 min) silently behaved as a flat "locked exactly 5 minutes after login"
# timer rather than the *idle* timeout it was designed as (per
# app_lock_controller.js, which only forces a re-check after real
# backgrounding) — any continuously-active flow longer than 5 minutes, like
# multi-step appointment creation, hit the PIN wall on its very next request.
RSpec.describe "PIN unlock timeout", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user, :onboarded) }

  before do
    user.update!(pin_digest: BCrypt::Password.create("1234"))
    post session_path, params: {email: user.email, password: "password123"}
  end

  it "does not re-lock a continuously active session, even past the raw timeout window" do
    travel_to(3.minutes.from_now) do
      get calendar_path
      expect(response.body).not_to include('data-pin-entry-target="input"')
    end

    # A second request, still well within PIN_TIMEOUT of the *previous*
    # request (even though it's now >5 minutes since the original login) —
    # this is exactly the shape of a multi-step appointment save.
    travel_to(6.minutes.from_now) do
      get calendar_path
      expect(response.body).not_to include('data-pin-entry-target="input"')
    end
  end

  it "does re-lock after real idle time with no requests in between" do
    travel_to(6.minutes.from_now) do
      get calendar_path
      expect(response.body).to include('data-pin-entry-target="input"')
    end
  end
end
