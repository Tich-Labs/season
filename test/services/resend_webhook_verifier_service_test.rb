require "test_helper"

class ResendWebhookVerifierServiceTest < ActiveSupport::TestCase
  SECRET = "whsec_dGVzdHNlY3JldGtleWZvcnNwZWNz" # "testsecretkeyforspecs", base64

  def sign(payload, secret: SECRET, svix_id: "msg_test123", timestamp: Time.current.to_i)
    secret_bytes = Base64.decode64(secret.delete_prefix("whsec_"))
    signed_content = "#{svix_id}.#{timestamp}.#{payload}"
    signature = Base64.strict_encode64(OpenSSL::HMAC.digest("sha256", secret_bytes, signed_content))
    {
      "svix-id" => svix_id,
      "svix-timestamp" => timestamp.to_s,
      "svix-signature" => "v1,#{signature}"
    }
  end

  test "accepts a correctly signed, fresh payload" do
    payload = {type: "email.bounced"}.to_json
    headers = sign(payload)

    assert ResendWebhookVerifierService.verify!(payload: payload, headers: headers, secret: SECRET)
  end

  test "rejects a payload signed with the wrong secret" do
    payload = {type: "email.bounced"}.to_json
    headers = sign(payload, secret: "whsec_d29ybmdzZWNyZXQ")

    assert_raises(ResendWebhookVerifierService::VerificationError) do
      ResendWebhookVerifierService.verify!(payload: payload, headers: headers, secret: SECRET)
    end
  end

  test "rejects a tampered payload (signature no longer matches)" do
    payload = {type: "email.bounced"}.to_json
    headers = sign(payload)
    tampered_payload = {type: "email.delivered"}.to_json

    assert_raises(ResendWebhookVerifierService::VerificationError) do
      ResendWebhookVerifierService.verify!(payload: tampered_payload, headers: headers, secret: SECRET)
    end
  end

  test "rejects a stale timestamp outside the tolerance window" do
    payload = {type: "email.bounced"}.to_json
    headers = sign(payload, timestamp: 1.hour.ago.to_i)

    assert_raises(ResendWebhookVerifierService::VerificationError) do
      ResendWebhookVerifierService.verify!(payload: payload, headers: headers, secret: SECRET)
    end
  end

  test "rejects when svix headers are missing" do
    payload = {type: "email.bounced"}.to_json

    assert_raises(ResendWebhookVerifierService::VerificationError) do
      ResendWebhookVerifierService.verify!(payload: payload, headers: {}, secret: SECRET)
    end
  end

  test "rejects when no secret is configured" do
    payload = {type: "email.bounced"}.to_json
    headers = sign(payload)

    assert_raises(ResendWebhookVerifierService::VerificationError) do
      ResendWebhookVerifierService.verify!(payload: payload, headers: headers, secret: nil)
    end
  end
end
