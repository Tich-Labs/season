# frozen_string_literal: true

require "base64"
require "jwt"
require "json"

# Thin client for the Google Play Developer API (Android closed testing).
#
# Exchanges a service-account JWT for an access token, then adds a beta
# tester's email to the configured closed-testing track. Google Play emails
# the tester an invite with a link to accept and install.
class GooglePlayClosedTestingService
  API_BASE = "https://androidpublisher.googleapis.com/androidpublisher/v3"
  SCOPE = "https://www.googleapis.com/auth/androidpublisher"
  TOKEN_URI = "https://oauth2.googleapis.com/token"
  TOKEN_TTL_SECONDS = 3600

  class Error < StandardError; end

  class << self
    delegate :invite, to: :new

    def configured?
      [
        ENV["GOOGLE_PLAY_SERVICE_ACCOUNT_JSON"],
        ENV["GOOGLE_PLAY_PACKAGE_NAME"],
        ENV["GOOGLE_PLAY_TRACK"]
      ].all?(&:present?)
    end
  end

  def invite(beta_tester)
    raise Error, "Google Play is not configured" unless self.class.configured?

    request(
      :post,
      "/applications/#{package_name}/testers/#{track}",
      body: {testers: [{emails: [beta_tester.email]}]}
    )
    true
  end

  private

  def request(method, path, body: nil)
    response = HTTParty.send(
      method,
      "#{API_BASE}#{path}",
      headers: {
        "Authorization" => "Bearer #{access_token}",
        "Content-Type" => "application/json"
      },
      body: body&.to_json,
      timeout: 20
    )

    return true if response.success?

    raise Error, "Google Play #{method.to_s.upcase} #{path} failed: #{response.code} #{response.body}"
  end

  def access_token
    @access_token ||= begin
      response = HTTParty.post(
        TOKEN_URI,
        headers: {"Content-Type" => "application/x-www-form-urlencoded"},
        body: URI.encode_www_form(
          grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
          assertion: assertion
        ),
        timeout: 20
      )

      raise Error, "Google OAuth token exchange failed: #{response.code} #{response.body}" unless response.success?

      response.parsed_response["access_token"]
    end
  end

  def assertion
    @assertion ||= JWT.encode(
      {
        iss: service_account["client_email"],
        scope: SCOPE,
        aud: TOKEN_URI,
        iat: Time.now.to_i,
        exp: Time.now.to_i + TOKEN_TTL_SECONDS
      },
      OpenSSL::PKey.read(service_account["private_key"]),
      "RS256"
    )
  end

  def service_account
    @service_account ||= JSON.parse(ENV["GOOGLE_PLAY_SERVICE_ACCOUNT_JSON"])
  end

  def package_name
    ENV["GOOGLE_PLAY_PACKAGE_NAME"].to_s
  end

  def track
    ENV["GOOGLE_PLAY_TRACK"].to_s
  end
end
