require "test_helper"

class AppLinksControllerTest < ActionDispatch::IntegrationTest
  test "apple app site association points to the iOS app" do
    with_env("APPLE_TEAM_ID", "TEAM123") do
      get "/.well-known/apple-app-site-association"
    end

    assert_response :success
    detail = response.parsed_body.dig("applinks", "details", 0)
    assert_equal "TEAM123.com.onrender.seasonv2.rubynative", detail["appID"]
    assert_includes detail["paths"], "/users/password/*"
  end

  test "assetlinks points to the Android app" do
    with_env("GOOGLE_PLAY_PACKAGE_NAME", "com.onrender.seasonv2.rubynative") do
      get "/.well-known/assetlinks.json"
    end

    assert_response :success
    target = response.parsed_body.dig(0, "target")
    assert_equal "android_app", target["namespace"]
    assert_equal "com.onrender.seasonv2.rubynative", target["package_name"]
    assert_includes target["sha256_cert_fingerprints"].first, "E3:52:3C:60"
  end
end
