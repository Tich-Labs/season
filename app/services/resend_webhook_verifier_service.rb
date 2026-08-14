# Verifies the Svix signature Resend attaches to every webhook delivery
# (Resend uses Svix under the hood for webhook fan-out — see
# https://resend.com/docs/dashboard/webhooks/verify-webhooks-requests).
# Without this, POST /webhooks/resend would trust any request body a caller
# hands it, including a forged "email.bounced" event naming an address that
# never actually bounced -- letting an attacker manufacture password-reset
# error states for arbitrary users.
class ResendWebhookVerifierService
  TOLERANCE = 5.minutes

  class VerificationError < StandardError; end

  def self.verify!(payload:, headers:, secret:)
    new(payload:, headers:, secret:).verify!
  end

  def initialize(payload:, headers:, secret:)
    @payload = payload
    @svix_id = headers["svix-id"]
    @svix_timestamp = headers["svix-timestamp"]
    @svix_signature = headers["svix-signature"]
    @secret = secret
  end

  def verify!
    raise VerificationError, "missing secret" if @secret.blank?
    raise VerificationError, "missing svix headers" if @svix_id.blank? || @svix_timestamp.blank? || @svix_signature.blank?
    raise VerificationError, "stale timestamp" unless timestamp_within_tolerance?
    raise VerificationError, "signature mismatch" unless signature_matches?
    true
  end

  private

  def timestamp_within_tolerance?
    sent_at = Time.zone.at(@svix_timestamp.to_i)
    (Time.current - sent_at).abs <= TOLERANCE
  rescue ArgumentError, TypeError
    false
  end

  def signature_matches?
    expected = expected_signature
    # svix-signature can carry multiple space-separated "v1,<sig>" candidates
    # (e.g. during secret rotation) -- valid if any one matches.
    @svix_signature.to_s.split(" ").any? do |candidate|
      version, sig = candidate.split(",", 2)
      next false unless version == "v1" && sig.present?
      secure_compare(sig, expected)
    end
  end

  def expected_signature
    secret_bytes = Base64.decode64(@secret.delete_prefix("whsec_"))
    signed_content = "#{@svix_id}.#{@svix_timestamp}.#{@payload}"
    Base64.strict_encode64(OpenSSL::HMAC.digest("sha256", secret_bytes, signed_content))
  end

  def secure_compare(a, b)
    ActiveSupport::SecurityUtils.secure_compare(a, b)
  rescue ArgumentError
    # secure_compare raises if lengths differ instead of just returning false
    false
  end
end
