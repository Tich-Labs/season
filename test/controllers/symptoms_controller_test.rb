require "test_helper"

# M3 — Symptom Logging
class SymptomsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
    sign_in_as(@alice)
  end

  test "GET /symptoms returns 200" do
    get symptoms_path
    assert_response :success
  end

  test "GET /symptoms requires authentication" do
    delete session_path
    get symptoms_path
    assert_redirected_to new_session_path
  end

  test "GET /symptoms/discharge returns 200" do
    get symptom_discharge_path
    assert_response :success
  end

  test "GET /symptoms/:id returns 200 for a valid log" do
    log = @alice.symptom_logs.create!(date: Time.zone.today, mood: 3)
    get symptom_path(log)
    assert_response :success
  end

  test "cannot view another user's symptom log" do
    bob_log = users(:bob).symptom_logs.create!(date: Time.zone.today, mood: 3)
    get symptom_path(bob_log)
    assert_response :not_found
  end

  test "POST /symptoms creates a symptom log" do
    assert_difference("SymptomLog.count", 1) do
      post symptoms_path, params: {symptom_log: {date: Time.zone.today.to_s, mood: 4, energy: 3}}
    end
  end

  test "POST /symptoms returns JSON ok" do
    post symptoms_path, params: {symptom_log: {date: 1.day.ago.to_date.to_s, mood: 2}}
    assert_response :success
    assert_equal "ok", response.parsed_body["status"]
  end

  test "POST /symptoms updates existing log for same date" do
    @alice.symptom_logs.create!(date: Time.zone.today, mood: 1)
    assert_no_difference("SymptomLog.count") do
      post symptoms_path, params: {symptom_log: {date: Time.zone.today.to_s, mood: 5}}
    end
    assert_equal 5, @alice.symptom_logs.find_by(date: Time.zone.today).mood
  end

  # Date guard — index
  test "GET /symptoms with valid date param returns 200" do
    get symptoms_path(date: 7.days.ago.to_date.to_s)
    assert_response :success
  end

  # Regression: the header phase used to always be computed for today, so
  # navigating back to a past date (or via ?date=) showed the wrong phase.
  test "GET /symptoms shows the phase for the viewed date, not today" do
    start = 14.days.ago.to_date
    luteal_date = start + 21
    get symptoms_path(date: luteal_date.to_s)
    assert_response :success
    assert_select "p", text: "Luteal Phase"
  end

  test "GET /symptoms shows today's phase without a date param" do
    get symptoms_path
    assert_response :success
    assert_select "p", text: "Ovulation Phase"
  end

  # Full-sequence check: the header must walk menstrual → follicular →
  # ovulation → luteal as the viewed date advances through the cycle.
  test "GET /symptoms shows the phase sequence across the cycle" do
    start = 14.days.ago.to_date
    {start => "Menstrual", start + 6 => "Follicular", start + 15 => "Ovulation", start + 22 => "Luteal"}.each do |date, phase|
      get symptoms_path(date: date.to_s)
      assert_response :success
      assert_select "p", text: "#{phase} Phase"
    end
  end

  test "GET /symptoms with garbage date param returns 200 (falls back to today)" do
    get symptoms_path(date: "not-a-date")
    assert_response :success
  end

  test "GET /symptoms with empty date param returns 200 (falls back to today)" do
    get symptoms_path(date: "")
    assert_response :success
  end

  # tracking_saved=1 is what triggers the post-save prediction modal on
  # /tracking -- see tracking_controller_test.rb.
  test "GET /symptoms Submit tracking link includes tracking_saved" do
    get symptoms_path
    assert_response :success
    assert_select "a[href='#{tracking_index_path(tracking_saved: 1)}']", text: "Submit tracking"
  end

  # Regression: date_picker_controller.js's open() looks for [data-selected]
  # to auto-scroll it into view, but nothing ever set that attribute here
  # (or on /superpowers, or /tracking) -- the auto-scroll was silently dead
  # on all three. See shared/_date_picker_drum.html.erb.
  test "GET /symptoms marks today as the selected day in the date picker" do
    get symptoms_path
    assert_response :success
    assert_select "a[data-selected='true']", text: Time.zone.today.strftime("%-d %B")
  end

  # Carry-over: when today's log has no sleep / temperature / weight, the
  # pickers pre-scroll to yesterday's values as a starting point (they are
  # only saved once the user picks something).
  test "GET /symptoms pre-fills sleep, temperature and weight from yesterday" do
    get symptoms_path
    assert_response :success
    assert_select "div[data-scroll-picker-field-value='sleep'][data-scroll-picker-start-value='7']"
    assert_select "div[data-scroll-picker-field-value='temperature'][data-scroll-picker-start-value='36.5']"
    assert_select "div[data-scroll-picker-field-value='weight'][data-scroll-picker-start-value='62.0']"
  end

  # Weight starts at 60 kg when there is nothing to carry over.
  test "GET /symptoms defaults the weight picker to 60 kg with no previous value" do
    symptom_logs(:alice_yesterday).destroy
    get symptoms_path
    assert_response :success
    assert_select "div[data-scroll-picker-field-value='weight'][data-scroll-picker-start-value='60.0']"
    assert_select "div[data-scroll-picker-field-value='sleep'][data-scroll-picker-start-value='']"
    assert_select "div[data-scroll-picker-field-value='temperature'][data-scroll-picker-start-value='']"
  end

  # A value already logged for the viewed day wins over the carry-over.
  test "GET /symptoms keeps today's saved values over the carry-over" do
    @alice.symptom_logs.create!(date: Time.zone.today, sleep: 8, temperature: 36.7, weight: 61.0)
    get symptoms_path
    assert_response :success
    assert_select "div[data-scroll-picker-field-value='sleep'] input[value='8']"
    assert_select "div[data-scroll-picker-field-value='temperature'] input[value='36.7']"
    assert_select "div[data-scroll-picker-field-value='weight'] input[value='61.0']"
  end
end
