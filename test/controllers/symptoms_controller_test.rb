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
end
