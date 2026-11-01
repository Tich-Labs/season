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

  test "GET /forecast shows Track my day for today" do
    get forecast_path
    assert_match(/href="#{Regexp.escape(tracking_index_path(date: Time.zone.today.to_s))}"/, response.body)
    assert_match(/Track my day/, response.body)
  end

  test "GET /forecast shows Track my day for a past date" do
    past = 5.days.ago.to_date
    get forecast_path(date: past.to_s)
    assert_match(/href="#{Regexp.escape(tracking_index_path(date: past.to_s))}"/, response.body)
  end

  # The button belongs to the Forecast tab only, not the Appointments tab.
  test "Track my day is inside the forecast tab, not the appointments tab" do
    get forecast_path
    body = response.body
    button = body.index('href="/tracking?date=')
    forecast_tab = body.index('data-forecast-tabs-target="forecast"')
    modal = body.index('data-forecast-modal-target="modal"')
    assert button, "Track my day button missing"
    assert_operator button, :>, forecast_tab
    assert_operator button, :<, modal
  end

  test "GET /forecast hides Track my day for a future date" do
    future = 3.days.from_now.to_date
    get forecast_path(date: future.to_s)
    assert_no_match(/Track my day/, response.body)
    assert_no_match(/href="#{Regexp.escape(tracking_index_path(date: future.to_s))}"/, response.body)
  end

  test "GET /forecast shows only the calendar button, not the + FAB" do
    get forecast_path
    assert_response :success
    assert_no_match(/quick-actions#open/, response.body)
    assert_match(/aria-label="Go to calendar"/, response.body)
    assert_no_match(/Back to calendar/, response.body)
  end
end
