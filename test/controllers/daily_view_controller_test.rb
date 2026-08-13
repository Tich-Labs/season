require "test_helper"

# M2 — Daily View
class DailyViewControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
    sign_in_as(@alice)
  end

  test "GET /daily/:date returns 200" do
    get daily_view_path(Time.zone.today.to_s)
    assert_response :success
  end

  test "GET /daily/today returns 200" do
    get daily_view_path("today")
    assert_response :success
  end

  test "GET /daily/:date requires authentication" do
    delete session_path
    get daily_view_path(Time.zone.today.to_s)
    assert_redirected_to new_session_path
  end

  test "GET /daily/:date shows the date" do
    date = Time.zone.today
    get daily_view_path(date.to_s)
    assert_match date.strftime("%B"), response.body
  end

  test "GET /daily/:date works for past dates" do
    get daily_view_path(30.days.ago.to_date.to_s)
    assert_response :success
  end

  test "GET /daily/:date works for future dates" do
    get daily_view_path(7.days.from_now.to_date.to_s)
    assert_response :success
  end

  # Reachable from the calendar-menu dropdown on /calendar or
  # /calendar/appointments, and from the burger menu on any page — back must
  # reflect the real referer, not assume it's always /calendar.
  test "back link reflects the burger menu's page as referer" do
    get daily_view_path(Time.zone.today.to_s), headers: {"HTTP_REFERER" => tracking_index_url}
    assert_match %r{href="/tracking"}, response.body
  end

  test "back link falls back to calendar with no referer" do
    get daily_view_path(Time.zone.today.to_s)
    assert_match %r{href="#{Regexp.escape(user_root_path(date: Time.zone.today.to_s))}"}, response.body
  end
end
