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
end
