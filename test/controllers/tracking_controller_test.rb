require "test_helper"

# M3 — Tracking / Self Analysis
class TrackingControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
    sign_in_as(@alice)
  end

  test "GET /tracking returns 200" do
    get tracking_index_path
    assert_response :success
  end

  test "GET /tracking requires authentication" do
    delete session_path
    get tracking_index_path
    assert_redirected_to new_session_path
  end

  test "GET /tracking/period returns 200" do
    get period_tracking_index_path
    assert_response :success
  end

  test "PATCH /tracking/period updates last_period_start and creates period_start log" do
    new_date = Time.zone.today
    patch period_tracking_index_path, params: {last_period_start: new_date.to_s}
    @alice.reload
    assert_equal new_date, @alice.last_period_start
    assert @alice.period_starts.exists?(started_on: new_date)
  end

  test "PATCH /tracking/period saves both start and end dates together" do
    start_date = 5.days.ago.to_date
    end_date = Time.zone.today
    patch period_tracking_index_path, params: {last_period_start: start_date.to_s, last_period_end: end_date.to_s}
    @alice.reload
    assert_equal start_date, @alice.last_period_start
    assert_equal end_date, @alice.last_period_end
  end

  test "PATCH /tracking/period rejects an end date before the start date" do
    patch period_tracking_index_path,
      params: {last_period_start: Time.zone.today.to_s, last_period_end: 3.days.ago.to_date.to_s}
    assert_redirected_to period_tracking_index_path
    @alice.reload
    assert_nil @alice.last_period_end
  end

  test "PATCH /tracking/period redirects after update" do
    patch period_tracking_index_path, params: {last_period_start: Time.zone.today.to_s}
    assert_response :redirect
  end

  # Regression: the post-tracking-save prediction modal used to be gated on
  # params[:period_saved], which nothing ever actually set on redirect --
  # the modal has never fired until now. Covers all three flows that feed
  # the same cycle prediction and share this one confirmation.
  test "PATCH /tracking/period redirects with tracking_saved so the prediction modal shows" do
    patch period_tracking_index_path, params: {last_period_start: Time.zone.today.to_s}
    assert_redirected_to tracking_index_path(tracking_saved: 1)
  end

  test "POST /tracking (period_start) redirects with tracking_saved so the prediction modal shows" do
    post tracking_index_path, params: {period_start: "1"}
    assert_redirected_to tracking_index_path(tracking_saved: 1)
  end

  test "GET /tracking?tracking_saved=1 renders the prediction modal" do
    get tracking_index_path(tracking_saved: 1)
    assert_response :success
    assert_select "#tracking-saved-modal"
    assert_match(/Your prediction will be adjusted based on the information you provide/, response.body)
  end

  test "GET /tracking without tracking_saved does not render the prediction modal" do
    get tracking_index_path
    assert_response :success
    assert_select "#tracking-saved-modal", false
  end
end
