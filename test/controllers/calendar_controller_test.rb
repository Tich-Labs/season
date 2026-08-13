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

  test "native app request does not double-apply safe-area-inset-bottom padding" do
    # The "native-inset" class (added when native_app?) already injects its own
    # safe-area-inset-bottom spacer via the ruby_native gem's CSS. The layout's
    # inline bottom padding must not also add env(safe-area-inset-bottom) on
    # native requests, or the inset gets counted twice.
    sign_in_as(@alice)
    get user_root_path, headers: {"User-Agent" => "Ruby Native iOS"}
    assert_response :success
    assert_match "padding-bottom: 8rem;", response.body
    assert_no_match(/padding-bottom: calc\(8rem \+ env\(safe-area-inset-bottom/, response.body)
  end

  test "web request still adds env(safe-area-inset-bottom) to bottom padding" do
    sign_in_as(@alice)
    get user_root_path
    assert_response :success
    assert_match "padding-bottom: calc(8rem + env(safe-area-inset-bottom, 0px));", response.body
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

  test "GET /calendar caps a 6-week month at 5 rows, dropping the trailing week" do
    sign_in_as(@alice)
    get user_root_path(date: "2026-08-01")
    assert_response :success
    # August 2026 needs a 6th calendar row — the grid intentionally caps at 5
    # rows, so that trailing week (31 Aug - 6 Sep) should not render.
    assert_no_match(/forecast\?date=2026-09-06/, response.body)
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
