require "test_helper"

class PinControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
    @alice.set_pin("1234")
    PinController::RATE_LIMIT_STORE.clear
  end

  test "logout clears pin_verified_at" do
    sign_in_as(@alice)

    get edit_settings_path
    assert_response :success
    assert_includes response.body, "pin-unlock-modal"

    post "/unlock", params: {pin: "1234"}

    get edit_settings_path
    assert_response :success
    assert_not_includes response.body, "pin-unlock-modal"

    delete session_path

    sign_in_as(@alice)

    get edit_settings_path
    assert_response :success
    assert_includes response.body, "pin-unlock-modal"
  end

  test "resume after under 5 min does not re-lock" do
    sign_in_as(@alice)

    get edit_settings_path
    assert_response :success
    assert_includes response.body, "pin-unlock-modal"

    post "/unlock", params: {pin: "1234"}

    get edit_settings_path
    assert_response :success
    assert_not_includes response.body, "pin-unlock-modal"
  end

  test "resume after 5+ min idle re-locks" do
    sign_in_as(@alice)

    get edit_settings_path
    assert_response :success
    assert_includes response.body, "pin-unlock-modal"

    post "/unlock", params: {pin: "1234"}

    travel_to 6.minutes.from_now do
      get edit_settings_path
      assert_response :success
      assert_includes response.body, "pin-unlock-modal"
    end
  end

  test "wrong PIN 6x within 15 min triggers rate limit" do
    sign_in_as(@alice)

    5.times do
      post "/unlock", params: {pin: "9999"}
      assert_response :unprocessable_entity
    end

    post "/unlock", params: {pin: "9999"}
    assert_response :too_many_requests

    travel_to 16.minutes.from_now do
      post "/unlock", params: {pin: "1234"}
      assert_redirected_to user_root_path
    end
  end
end
