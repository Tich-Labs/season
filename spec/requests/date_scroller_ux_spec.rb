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

  it "uses 3-letter weekday abbreviations in the picker JS, not ambiguous single letters" do
    js = Rails.root.join("app/javascript/controllers/appointment_date_picker_controller.js").read
    expect(js).to include("['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']")
  end
end
