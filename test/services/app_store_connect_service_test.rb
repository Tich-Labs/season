# frozen_string_literal: true

require "test_helper"

class AppStoreConnectServiceTest < ActiveSupport::TestCase
  FakeResponse = Struct.new(:code, :parsed) do
    def body = parsed.to_json
    def success? = (200..299).cover?(code)
    def parsed_response = parsed
  end

  APPSTORE_ENV_KEYS = %w[
    APPSTORE_KEY_ID
    APPSTORE_ISSUER_ID
    APPSTORE_KEY_BASE64
    APPSTORE_APP_ID
    APPSTORE_BETA_GROUP_ID
  ].freeze

  setup do
    ec_key = OpenSSL::PKey::EC.generate("prime256v1")
    ENV["APPSTORE_KEY_ID"] = "KEY123"
    ENV["APPSTORE_ISSUER_ID"] = "issuer-1"
    ENV["APPSTORE_KEY_BASE64"] = Base64.encode64(ec_key.to_pem)
    ENV["APPSTORE_APP_ID"] = "app-123"
    ENV["APPSTORE_BETA_GROUP_ID"] = "group-456"
  end

  teardown do
    APPSTORE_ENV_KEYS.each { |k| ENV.delete(k) }
  end

  def tester
    @tester ||= BetaTester.new(
      name: "Alice Smith",
      email: "alice@example.com",
      platform: "ios",
      beta_consent: true
    )
  end

  # Stubs HTTParty.send, returning the given [code, parsed] responses in
  # order. Returns the recorded [method, url, json_body] triples.
  def with_fake_api(*responses)
    calls = []
    responder = lambda do |method, url, **opts|
      calls << [method, url, opts[:body]]
      code, parsed = responses.shift
      FakeResponse.new(code, parsed)
    end

    stub_class_method(HTTParty, :send, responder) { yield }
    calls
  end

  test "configured? is false without the required env vars" do
    APPSTORE_ENV_KEYS.each { |k| ENV.delete(k) }
    assert_not AppStoreConnectService.configured?
  end

  test "configured? is true when every env var is set" do
    assert AppStoreConnectService.configured?
  end

  test "reuses an existing tester and invites them" do
    calls = with_fake_api(
      [200, {"data" => [{"id" => "tester-1"}]}], # GET find → already exists
      [204, nil],                                # POST add to group
      [204, nil]                                 # POST invitation
    ) do
      AppStoreConnectService.invite(tester)
    end

    assert_equal 3, calls.length
    assert_equal [:get, "https://api.appstoreconnect.apple.com/v1/betaTesters?filter[email]=alice%40example.com", nil], calls[0]
    assert_equal :post, calls[1][0]
    assert_match %r{/v1/betaGroups/group-456/relationships/betaTesters\z}, calls[1][1]
    assert_equal [{"type" => "betaTesters", "id" => "tester-1"}], JSON.parse(calls[1][2])["data"]

    invite_body = JSON.parse(calls[2][2])
    assert_equal "app-123", invite_body.dig("data", "relationships", "app", "data", "id")
    assert_equal "tester-1", invite_body.dig("data", "relationships", "betaTester", "data", "id")
  end

  test "creates a missing tester before adding them to the group" do
    calls = with_fake_api(
      [200, {"data" => []}],                    # GET find → none
      [201, {"data" => {"id" => "new-1"}}],     # POST create
      [204, nil],                               # POST add to group
      [204, nil]                                # POST invitation
    ) do
      AppStoreConnectService.invite(tester)
    end

    create_body = JSON.parse(calls[1][2])
    assert_equal "alice@example.com", create_body.dig("data", "attributes", "email")
    assert_equal "Alice", create_body.dig("data", "attributes", "firstName")
    assert_equal "Smith", create_body.dig("data", "attributes", "lastName")
  end

  test "handles a concurrent-create conflict by re-fetching" do
    calls = with_fake_api(
      [200, {"data" => []}],                          # GET find → none
      [409, nil],                                     # POST create → conflict
      [200, {"data" => [{"id" => "other-1"}]}],       # GET refetch
      [204, nil],                                     # POST add to group
      [204, nil]                                      # POST invitation
    ) do
      AppStoreConnectService.invite(tester)
    end

    assert_equal 5, calls.length
    assert_equal :get, calls[2][0]
    assert_match(/filter\[email\]=/, calls[2][1])
    assert_equal :post, calls[3][0]
    assert_match %r{/v1/betaGroups/group-456/relationships/betaTesters\z}, calls[3][1]
  end

  test "raises AppStoreConnectService::Error on an API failure" do
    fake = ->(*_args, **_kwargs) { FakeResponse.new(401, {"errors" => []}) }
    stub_class_method(HTTParty, :send, fake) do
      assert_raises(AppStoreConnectService::Error) do
        AppStoreConnectService.invite(tester)
      end
    end
  end

  test "raises when not configured" do
    APPSTORE_ENV_KEYS.each { |k| ENV.delete(k) }
    assert_raises(AppStoreConnectService::Error) do
      AppStoreConnectService.invite(tester)
    end
  end
end
