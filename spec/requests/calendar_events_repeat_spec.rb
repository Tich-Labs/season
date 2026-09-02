require "rails_helper"

# Functional coverage for the "Repeat this event" feature's data model:
# pattern (daily/weekly/monthly/yearly/custom:N:unit) and duration
# (endless/until:date/count:N) are two independent facets of one
# recurrence rule that must combine into a single repeat_frequency value —
# this is the layer RSpec can actually reach (the real Rails form
# submission + persistence); the Stimulus-side combining logic itself has
# no JS test framework available in this app to exercise directly.
#
# Doesn't cover recurrence *expansion* (turning repeat_frequency into
# actual calendar occurrences) — that doesn't exist yet, tracked
# separately in docs/M4.md.
RSpec.describe "CalendarEvents repeat_frequency", type: :request do
  # This app's current_user is its own session[:user_id]-based
  # Authentication concern (app/controllers/concerns/authentication.rb),
  # entirely separate from Devise's Warden session — Devise is only
  # mounted for password recovery/OmniAuth here. Devise::Test's `sign_in`
  # sets the Warden session, which this app's current_user never reads, so
  # it silently doesn't authenticate (a 302 back to the login page, not an
  # error) — driving the real POST /session login flow is what actually
  # establishes session[:user_id].
  let(:user) { create(:user, :onboarded) }

  before { post session_path, params: {email: user.email, password: "password123"} }

  def create_event(repeat_frequency:)
    post calendar_events_path, params: {
      calendar_event: {
        title: "Test appointment",
        date: Time.zone.tomorrow,
        start_time: "10:00",
        end_time: "11:00",
        repeat_frequency: repeat_frequency
      }
    }
    CalendarEvent.last
  end

  describe "bare patterns (no duration suffix = endless)" do
    %w[daily weekly monthly yearly].each do |pattern|
      it "persists #{pattern} exactly" do
        event = create_event(repeat_frequency: pattern)
        expect(event.repeat_frequency).to eq(pattern)
      end
    end
  end

  describe "custom pattern — one interval, not three" do
    it "persists an every-N-days interval" do
      event = create_event(repeat_frequency: "custom:3:days")
      expect(event.repeat_frequency).to eq("custom:3:days")
    end

    it "persists an every-N-weeks interval" do
      event = create_event(repeat_frequency: "custom:2:weeks")
      expect(event.repeat_frequency).to eq("custom:2:weeks")
    end

    it "persists an every-N-months interval" do
      event = create_event(repeat_frequency: "custom:6:months")
      expect(event.repeat_frequency).to eq("custom:6:months")
    end
  end

  describe "pattern + duration combined — the bug this covers" do
    # Before the fix, confirmRepeat()/confirmCustomRepeat()/
    # confirmRepeatUntil()/#applyRepeatCount() each unconditionally
    # overwrote the whole repeatField with just their own piece, so only
    # one of these seven shapes could ever be saved — never a real
    # combination like "weekly until a date" or "custom interval, N
    # times". These values are what the fixed JS now actually produces;
    # asserting the controller round-trips them exactly (not silently
    # truncating to just the pattern or just the duration) is what proves
    # the combination survives all the way to the database.
    it "persists a fixed pattern with an until-date" do
      event = create_event(repeat_frequency: "weekly|until:2028-10-16")
      expect(event.repeat_frequency).to eq("weekly|until:2028-10-16")
    end

    it "persists a fixed pattern with a count" do
      event = create_event(repeat_frequency: "monthly|count:5")
      expect(event.repeat_frequency).to eq("monthly|count:5")
    end

    it "persists a custom interval with an until-date" do
      event = create_event(repeat_frequency: "custom:2:weeks|until:2028-10-16")
      expect(event.repeat_frequency).to eq("custom:2:weeks|until:2028-10-16")
    end

    it "persists a custom interval with a count" do
      event = create_event(repeat_frequency: "custom:3:days|count:10")
      expect(event.repeat_frequency).to eq("custom:3:days|count:10")
    end
  end

  describe "updating an existing event's repeat_frequency" do
    it "replaces one combined value with another, not merges them" do
      event = create_event(repeat_frequency: "weekly|until:2028-10-16")

      patch calendar_event_path(event), params: {
        calendar_event: {title: event.title, date: event.date, repeat_frequency: "monthly|count:3"}
      }

      expect(event.reload.repeat_frequency).to eq("monthly|count:3")
    end
  end
end
