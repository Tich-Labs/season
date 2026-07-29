require "test_helper"

# M1 + M7 — Onboarding
class OnboardingControllerTest < ActionDispatch::IntegrationTest
  def setup
    @carol = users(:carol)
  end

  test "GET /onboarding/1 redirects to next incomplete step" do
    sign_in_as(@carol)
    get onboarding_path(1)
    assert_redirected_to onboarding_path(2)
  end

  test "GET /onboarding/1 is accessible without login" do
    get onboarding_path(1)
    assert_response :success
  end

  test "GET /onboarding/finish is accessible" do
    sign_in_as(@carol)
    get onboarding_finish_path
    assert_response :success
  end

  test "PATCH /onboarding/9 saves cycle stage reminder and advances" do
    sign_in_as(@carol)
    patch onboarding_path(9), params: {}
    assert_response :redirect
    assert_equal true, @carol.reload.cycle_stage_reminder
  end

  test "GET /onboarding redirects to calendar if onboarding already complete" do
    sign_in_as(users(:alice))
    get onboarding_path(1)
    assert_redirected_to user_root_path
  end

  # Date guard — step 3 (combined start/end range picker)
  test "PATCH /onboarding/3 with valid ISO start date saves last_period_start and creates period_start log" do
    sign_in_as(@carol)
    patch onboarding_path(3), params: {last_period_start: 10.days.ago.to_date.to_s}
    assert_response :redirect
    assert_not_nil @carol.reload.last_period_start
    assert @carol.period_starts.exists?(started_on: 10.days.ago.to_date)
  end

  test "PATCH /onboarding/3 with start and end date saves both" do
    sign_in_as(@carol)
    patch onboarding_path(3), params: {
      last_period_start: 10.days.ago.to_date.to_s,
      last_period_end: 5.days.ago.to_date.to_s
    }
    assert_response :redirect
    @carol.reload
    assert_not_nil @carol.last_period_start
    assert_not_nil @carol.last_period_end
  end

  test "PATCH /onboarding/3 with garbage date returns 422 not 500" do
    sign_in_as(@carol)
    patch onboarding_path(3), params: {last_period_start: "not-a-date"}
    assert_response :unprocessable_entity
  end

  test "PATCH /onboarding/3 with empty date returns 422 not 500" do
    sign_in_as(@carol)
    patch onboarding_path(3), params: {last_period_start: ""}
    assert_response :unprocessable_entity
  end

  test "PATCH /onboarding/3 with skip_last_period advances without saving date" do
    sign_in_as(@carol)
    patch onboarding_path(3), params: {skip_last_period: "1"}
    assert_response :redirect
  end
end
