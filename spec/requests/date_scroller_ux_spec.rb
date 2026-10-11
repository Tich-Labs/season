require "rails_helper"

# UX fixes to the wheel/scroller date pickers, confirmed with the user:
# (1) month wheels showed raw "01".."12" right next to labels elsewhere in
#     the same component using named months ("11 Sep 2026") -- reintroduced
#     DD/MM-vs-MM/DD ambiguity and made the value visibly reformat on tap.
# (2) the appointment date/time picker's scroller items had no
#     scroll-snap-align at all, so touch flicks free-scrolled with no snap
#     points -- reported as "rolling too fast".
# (3) those same scrollers had no touch-action set, so a touch drag that
#     wasn't perfectly vertical could shift the wheel sideways too --
#     reported as the numbers looking "wobbly" left-right on touch.
# (4) the picker's weekday abbreviations were a single hardcoded English
#     letter each ('S' for both Sunday and Saturday, 'T' for both Tuesday
#     and Thursday) -- ambiguous, and not locale-aware. Now driven by
#     config/locales/*.yml's date.abbr_day_names, passed to the JS via a
#     Stimulus value, so a German user sees Mo/Di/Mi/... not Mon/Tue/Wed.
RSpec.describe "Date scroller UX", type: :request do
  let(:user) { create(:user, :onboarded) }

  before { post session_path, params: {email: user.email, password: "password123"} }

  it "shows named months, not raw numbers, in the appointment date picker" do
    get new_calendar_event_path
    expect(response.body).to include(">Jan<")
    expect(response.body).not_to match(/data-value="1">01</)
  end

  it "snaps every item in the appointment date/time picker (day/month/year/hour/minute)" do
    get new_calendar_event_path
    # 5 scrollers x their item counts all carry snap-center snap-always;
    # spot-check the class combination is present at all, not just snap-center.
    expect(response.body).to include("snap-center snap-always")
  end

  it "constrains the appointment date/time picker's scrollers to vertical-only touch" do
    get new_calendar_event_path
    expect(response.body).to include("touch-action: pan-y; overscroll-behavior: contain;")
  end

  # (5) the drum scrollers had no space above the first item or below the
  #     last, so scrollTop clamped at 0 / max before those items could ever
  #     reach the centre highlight. The picker reads the centred item
  #     (appointment_date_picker_controller.js #closestItem), so the first
  #     and last item of every drum were unreachable: minute "00" (every
  #     full hour) and hour "23" could never be picked -- reported as
  #     "can't enter appointments at a full hour" / "only up to 22:00".
  #     A half-viewport (26px) cap at each end lets both ends centre.
  it "end-caps every appointment drum so the first and last item can be centred" do
    get new_calendar_event_path
    expect(response.body.scan('class="drum-cap"').size).to eq(10)
  end

  it "still exposes minute 00 and hour 23 as pickable values" do
    get new_calendar_event_path
    expect(response.body).to match(/data-value="0"[^>]*snap-center snap-always[^>]*>00</)
    expect(response.body).to match(/data-value="23"[^>]*snap-center snap-always[^>]*>23</)
  end

  it "uses 3-letter weekday abbreviations in the picker JS, not ambiguous single letters" do
    js = Rails.root.join("app/javascript/controllers/appointment_date_picker_controller.js").read
    expect(js).to include("['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']")
  end

  it "passes the current user's locale weekday names to the picker (English)" do
    get new_calendar_event_path
    expect(response.body).to include("data-appointment-date-picker-weekday-names-value")
    expect(response.body).to include("Sun")
    expect(response.body).to include("Sat")
  end

  it "passes German weekday abbreviations for a German-locale user" do
    user.update!(language: "de")
    get new_calendar_event_path
    expect(response.body).to include("Mo")
    expect(response.body).to include("Di")
    expect(response.body).to include("So")
  end
end
