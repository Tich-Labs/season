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

  # The calendar-menu dropdown (calendar/index.html.erb) links to these two
  # routes alongside /calendar and /daily/:date. Both of those were already
  # covered by a path-configuration rule but these two weren't, leaving native
  # navigation for them undefined — reported as an iOS-only error clicking
  # "Schedule Overview" / "Weekly-View" from the dropdown (worked fine on web).
  test "ios_v1 covers /calendar/appointments and /calendar/weekly" do
    get "/configurations/ios_v1"
    json = response.parsed_body
    default_patterns = json["rules"].flat_map { |r| r["patterns"] }
    assert_includes default_patterns, "/calendar/appointments"
    assert_includes default_patterns, "/calendar/weekly"
  end

  test "android_v1 covers /calendar/appointments and /calendar/weekly" do
    get "/configurations/android_v1"
    json = response.parsed_body
    default_patterns = json["rules"].flat_map { |r| r["patterns"] }
    assert_includes default_patterns, "/calendar/appointments"
    assert_includes default_patterns, "/calendar/weekly"
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
