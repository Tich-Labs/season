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

  test "PATCH /tracking/period updates last_period_start" do
    new_date = Time.zone.today
    patch period_tracking_index_path, params: {period: {date: new_date.to_s}}
    @alice.reload
    assert_equal new_date, @alice.last_period_start
  end

  test "PATCH /tracking/period redirects after update" do
    patch period_tracking_index_path, params: {period_start: Time.zone.today.to_s}
    assert_response :redirect
  end
end
