require "test_helper"

# M4 — Forecast
class ForecastControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
    sign_in_as(@alice)
  end

  test "GET /forecast returns 200" do
    get forecast_path
    assert_response :success
  end

  test "GET /forecast requires authentication" do
    delete session_path
    get forecast_path
    assert_redirected_to new_session_path
  end

  # Date guard
  test "GET /forecast with valid date param returns 200" do
    get forecast_path(date: 30.days.from_now.to_date.to_s)
    assert_response :success
  end

  test "GET /forecast with garbage date param returns 200 (falls back to today)" do
    get forecast_path(date: "not-a-date")
    assert_response :success
  end

  test "GET /forecast with empty date param returns 200 (falls back to today)" do
    get forecast_path(date: "")
    assert_response :success
  end
end
