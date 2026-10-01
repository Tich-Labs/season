# frozen_string_literal: true

require "test_helper"

class GooglePlayClosedTestingServiceTest < ActiveSupport::TestCase
  FakeResponse = Struct.new(:code, :parsed) do
    def body = parsed.to_json
    def success? = (200..299).cover?(code)
    def parsed_response = parsed
  end

  GOOGLE_PLAY_ENV_KEYS = %w[
    GOOGLE_PLAY_SERVICE_ACCOUNT_JSON
    GOOGLE_PLAY_PACKAGE_NAME
    GOOGLE_PLAY_TRACK
  ].freeze

  setup do
    key = OpenSSL::PKey::RSA.generate(2048)
    service_account = {
      client_email: "season-play@project.iam.gserviceaccount.com",
      private_key: key.to_pem,
      token_uri: "https://oauth2.googleapis.com/token"
    }
    ENV["GOOGLE_PLAY_SERVICE_ACCOUNT_JSON"] = service_account.to_json
    ENV["GOOGLE_PLAY_PACKAGE_NAME"] = "com.seasonapp.android"
    ENV["GOOGLE_PLAY_TRACK"] = "beta"
  end

  teardown do
    GOOGLE_PLAY_ENV_KEYS.each { |k| ENV.delete(k) }
  end

  def tester
    @tester ||= BetaTester.new(
      name: "Alice Smith",
      email: "alice@example.com",
      platform: "android",
      beta_consent: true
    )
  end

  # Stubs the OAuth token exchange (HTTParty.post) and the API call
  # (HTTParty.send), returning the recorded API [method, url, json_body].
  def with_fake_api(api_status: 200)
    calls = []
    responder = lambda do |method, url, **opts|
      calls << [method, url, opts[:body]]
      FakeResponse.new(api_status, nil)
    end

    stub_class_method(HTTParty, :post, ->(_url, **_opts) { FakeResponse.new(200, {"access_token" => "tok-1"}) }) do
      stub_class_method(HTTParty, :send, responder) { yield }
    end
    calls
  end

  test "configured? is false without the required env vars" do
    GOOGLE_PLAY_ENV_KEYS.each { |k| ENV.delete(k) }
    assert_not GooglePlayClosedTestingService.configured?
  end

  test "configured? is true when every env var is set" do
    assert GooglePlayClosedTestingService.configured?
  end

  test "adds a tester to the configured closed track" do
    calls = with_fake_api do
      GooglePlayClosedTestingService.invite(tester)
    end

    assert_equal 1, calls.length
    method, url, body = calls[0]
    assert_equal :post, method
    assert_equal "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/com.seasonapp.android/testers/beta", url
    assert_equal({"testers" => [{"emails" => ["alice@example.com"]}]}, JSON.parse(body))
  end

  test "raises GooglePlayClosedTestingService::Error on an API failure" do
    with_fake_api(api_status: 403) do
      assert_raises(GooglePlayClosedTestingService::Error) do
        GooglePlayClosedTestingService.invite(tester)
      end
    end
  end

  test "raises when not configured" do
    GOOGLE_PLAY_ENV_KEYS.each { |k| ENV.delete(k) }
    assert_raises(GooglePlayClosedTestingService::Error) do
      GooglePlayClosedTestingService.invite(tester)
    end
  end
end
