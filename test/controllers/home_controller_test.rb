require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
    @bob = users(:bob)
    # bob's fixture is missing a couple of REQUIRED_ONBOARDING_STEPS fields —
    # fill them in so require_onboarding_completed doesn't redirect before
    # the loader/pin logic under test even runs.
    @bob.update!(birthday: 25.years.ago.to_date, has_regular_cycle: true,
      uses_hormonal_birth_control: false, food_preference: "None")
  end

  test "loader redirects straight to calendar with pin pending when locked" do
    @alice.set_pin("1234")
    sign_in_as(@alice)

    get loader_path
    assert_response :success
    assert_match(/data-loader-pin-pending-value="true"/, response.body)
    assert_match(/data-loader-calendar-url-value="#{Regexp.escape(user_root_path)}"/, response.body)
  end

  test "loader goes to calendar with pin pending false when no pin is set" do
    sign_in_as(@bob)

    get loader_path
    assert_response :success
    assert_match(/data-loader-pin-pending-value="false"/, response.body)
  end

  test "loader goes to calendar with pin pending false when already verified" do
    @alice.set_pin("1234")
    sign_in_as(@alice)
    post "/unlock", params: {pin: "1234"}

    get loader_path
    assert_response :success
    assert_match(/data-loader-pin-pending-value="false"/, response.body)
  end

  # /app is what SceneDelegate.swift's cold-launch entry point routes to
  # instead of the bare domain root, specifically so an already-logged-in
  # native user skips straight to calendar instead of seeing the
  # Login/Create Account welcome screen flash by first.
  test "GET /app redirects an authenticated user straight to calendar" do
    sign_in_as(@bob)
    get app_landing_path
    assert_redirected_to user_root_path
  end

  test "GET /app redirects a signed-out user to welcome" do
    get app_landing_path
    assert_redirected_to welcome_path
  end

  test "welcome shows create account as primary for a device that has never logged in" do
    get welcome_path
    assert_response :success
    assert_includes response.body, "Create Account"
    assert_includes response.body, "I already have an account"
    assert_not_includes response.body, ">Login<"
  end

  test "welcome shows login as primary for a returning device after logout" do
    sign_in_as(@alice)
    delete session_path

    get welcome_path
    assert_response :success
    assert_includes response.body, ">Login<"
    assert_not_includes response.body, "I already have an account"
  end
end
