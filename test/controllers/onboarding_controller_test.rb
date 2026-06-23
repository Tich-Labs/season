require "test_helper"

# M1 + M7 — Onboarding
class OnboardingControllerTest < ActionDispatch::IntegrationTest
  def setup
    @carol = users(:carol)
  end

  test "GET /onboarding/1 renders step 1" do
    sign_in_as(@carol)
    get onboarding_path(1)
    assert_response :success
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

  test "PATCH /onboarding/10 saves last period date and advances" do
    sign_in_as(@carol)
    patch onboarding_path(10), params: {
      last_period_date: 14.days.ago.to_date.to_s
    }
    assert_response :redirect
  end

  test "GET /onboarding redirects to calendar if onboarding already complete" do
    sign_in_as(users(:alice))
    get onboarding_path(1)
    assert_redirected_to user_root_path
  end

  # Date guard — step 3
  test "PATCH /onboarding/3 with valid ISO date saves last_period_start" do
    sign_in_as(@carol)
    patch onboarding_path(3), params: {last_period_start: 10.days.ago.to_date.to_s}
    assert_response :redirect
    assert_not_nil @carol.reload.last_period_start
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

  # Date guard — step 4
  test "PATCH /onboarding/4 with valid ISO date saves last_period_end" do
    sign_in_as(@carol)
    patch onboarding_path(4), params: {last_period_end: 5.days.ago.to_date.to_s}
    assert_response :redirect
    assert_not_nil @carol.reload.last_period_end
  end

  test "PATCH /onboarding/4 with garbage date returns 422 not 500" do
    sign_in_as(@carol)
    patch onboarding_path(4), params: {last_period_end: "not-a-date"}
    assert_response :unprocessable_entity
  end

  test "PATCH /onboarding/4 with empty date returns 422 not 500" do
    sign_in_as(@carol)
    patch onboarding_path(4), params: {last_period_end: ""}
    assert_response :unprocessable_entity
  end

  test "PATCH /onboarding/3 with skip_last_period advances without saving date" do
    sign_in_as(@carol)
    patch onboarding_path(3), params: {skip_last_period: "1"}
    assert_response :redirect
  end
end
