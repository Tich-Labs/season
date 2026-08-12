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
    assert_match "2026", response.body
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
    assert_redirected_to onboarding_path(2)
  end

  test "GET /calendar renders tracked-day tick when show_tracked_days enabled" do
    sign_in_as(@alice)
    get user_root_path(date: "2026-08-01")
    assert_includes response.body, "1.35512"
  end

  test "GET /calendar hides tracked-day tick when show_tracked_days disabled" do
    @alice.update!(show_tracked_days: false)
    sign_in_as(@alice)
    get user_root_path(date: "2026-08-01")
    assert_not_includes response.body, "1.35512"
  end

  # M1 — first-instance state: an onboarded user with no period data yet sees
  # the unfilled calendar and no FAB at all (neither "+" nor calendar-home;
  # the latter was already hidden on this page regardless of data).
  test "GET /calendar shows no FAB at all for a first-instance user with no period data" do
    first_instance_user = User.create!(
      email: "firstinstance@example.com", name: "Test", password: "password123", password_confirmation: "password123",
      birthday: 30.years.ago, has_regular_cycle: true, uses_hormonal_birth_control: false,
      food_preference: "omnivore", onboarding_completed: true
    ).tap(&:confirm)

    sign_in_as(first_instance_user)
    get user_root_path
    assert_response :success
    assert_no_match(/quick-actions#open/, response.body)
    assert_no_match(/Back to calendar/, response.body)
  end
end
