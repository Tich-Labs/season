# frozen_string_literal: true

require "base64"
require "jwt"

# Thin client for the App Store Connect API (TestFlight beta testing).
#
# Signs a short-lived ES256 JWT with the team API key and invites a beta
# tester to the configured external testing group. Every step is idempotent:
# a tester that already exists is reused, a tester already in the group
# returns 409 CONFLICT (treated as success), and a repeat invitation is the
# same.
class AppStoreConnectService
  API_BASE = "https://api.appstoreconnect.apple.com"
  AUDIENCE = "appstoreconnect-v1"
  TOKEN_TTL_SECONDS = 1200

  class Error < StandardError; end

  class << self
    def configured?
      [
        ENV["APPSTORE_KEY_ID"],
        ENV["APPSTORE_ISSUER_ID"],
        ENV["APPSTORE_KEY_BASE64"],
        ENV["APPSTORE_APP_ID"],
        ENV["APPSTORE_BETA_GROUP_ID"]
      ].all?(&:present?)
    end

    delegate :invite, to: :new
  end

  def invite(beta_tester)
    raise Error, "App Store Connect is not configured" unless self.class.configured?

    tester = find_or_create_tester(beta_tester)
    add_to_group(tester["id"])
    send_invitation(tester["id"])
    true
  end

  private

  def find_or_create_tester(beta_tester)
    email = beta_tester.email
    existing = request(:get, "/v1/betaTesters?filter[email]=#{CGI.escape(email)}")
    return existing.dig("data", 0) if existing.dig("data", 0).present?

    first_name, last_name = name_parts(beta_tester.name)
    created = request(
      :post,
      "/v1/betaTesters",
      body: {
        data: {
          type: "betaTesters",
          attributes: {
            email: email,
            firstName: first_name,
            lastName: last_name
          }
        }
      }
    )
    return created["data"] if created != :conflict

    # Lost a race with a concurrent registration: fetch the tester created by
    # the other job instead of failing.
    request(:get, "/v1/betaTesters?filter[email]=#{CGI.escape(email)}").dig("data", 0)
  end

  def add_to_group(tester_id)
    request(
      :post,
      "/v1/betaGroups/#{beta_group_id}/relationships/betaTesters",
      body: {data: [{type: "betaTesters", id: tester_id}]}
    )
  end

  def send_invitation(tester_id)
    request(
      :post,
      "/v1/betaTesterInvitations",
      body: {
        data: {
          type: "betaTesterInvitations",
          relationships: {
            betaTester: {data: {type: "betaTesters", id: tester_id}},
            app: {data: {type: "apps", id: app_id}}
          }
        }
      }
    )
  end

  def request(method, path, body: nil)
    response = HTTParty.send(
      method,
      "#{API_BASE}#{path}",
      headers: headers,
      body: body&.to_json,
      timeout: 20
    )

    return response.parsed_response if response.success?
    # 409 CONFLICT means the resource/relationship already exists — the
    # desired end state is already true, so it is not an error.
    return :conflict if response.code == 409

    raise Error, "App Store Connect #{method.to_s.upcase} #{path} failed: #{response.code} #{response.body}"
  end

  def headers
    {"Authorization" => "Bearer #{token}", "Content-Type" => "application/json"}
  end

  def token
    @token ||= JWT.encode(
      {
        iss: issuer_id,
        iat: Time.now.to_i,
        exp: Time.now.to_i + TOKEN_TTL_SECONDS,
        aud: AUDIENCE
      },
      private_key,
      "ES256",
      {kid: key_id}
    )
  end

  def private_key
    @private_key ||= OpenSSL::PKey.read(Base64.decode64(key_base64))
  end

  def name_parts(name)
    first, last = name.to_s.strip.split(/\s+/, 2)
    [first.presence || "Beta Tester", last.to_s.strip]
  end

  def key_id
    ENV["APPSTORE_KEY_ID"].to_s
  end

  def issuer_id
    ENV["APPSTORE_ISSUER_ID"].to_s
  end

  def key_base64
    ENV["APPSTORE_KEY_BASE64"].to_s
  end

  def app_id
    ENV["APPSTORE_APP_ID"].to_s
  end

  def beta_group_id
    ENV["APPSTORE_BETA_GROUP_ID"].to_s
  end
end
