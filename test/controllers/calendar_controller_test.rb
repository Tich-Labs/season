require "test_helper"

class CalendarControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
  end

  test "GET /calendar redirects to login when not signed in" do
    get user_root_path
    assert_redirected_to new_session_path
  end

  test "GET /calendar returns 200 when signed in" do
    sign_in_as(@alice)
    get user_root_path
    assert_response :success
  end

  test "GET /calendar?date= renders the requested month" do
    sign_in_as(@alice)
    get user_root_path(date: "2026-06-01")
    assert_response :success
    assert_match "June", response.body
  end

  test "GET /calendar with a different month date does not raise" do
    sign_in_as(@alice)
    get user_root_path(date: "2025-12-01")
    assert_response :success
  end

  test "GET /calendar redirects to onboarding when user has not completed it" do
    carol = users(:carol)
    sign_in_as(carol)
    get user_root_path
    assert_redirected_to onboarding_path(1)
  end
end
