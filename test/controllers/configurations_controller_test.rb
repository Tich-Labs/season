require "test_helper"

class ConfigurationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
  end

  test "ios_v1 returns JSON for unauthenticated request" do
    get "/configurations/ios_v1"
    assert_response :success
    json = response.parsed_body
    assert json.key?("rules")
    assert_kind_of Array, json["rules"]
  end

  test "ios_v1 returns JSON for authenticated user with PIN set and expired pin_verified_at" do
    @alice.set_pin("1234")
    sign_in_as(@alice)

    post "/unlock", params: {pin: "1234"}
    assert_redirected_to user_root_path

    travel_to 6.minutes.from_now do
      get "/configurations/ios_v1"
      assert_response :success
      json = response.parsed_body
      assert json.key?("rules")
    end
  end
end
