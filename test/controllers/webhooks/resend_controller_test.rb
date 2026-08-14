require "test_helper"

class Webhooks::ResendControllerTest < ActionDispatch::IntegrationTest
  SECRET = "whsec_dGVzdHNlY3JldGtleWZvcnNwZWNz"

  def setup
    @user = User.create!(
      email: "bouncetest@example.com", name: "Test", password: "password123", password_confirmation: "password123"
    ).tap(&:confirm)
    ENV["RESEND_WEBHOOK_SECRET"] = SECRET
  end

  def teardown
    ENV.delete("RESEND_WEBHOOK_SECRET")
  end

  def signed_headers(payload, svix_id: "msg_test123", timestamp: Time.current.to_i)
    secret_bytes = Base64.decode64(SECRET.delete_prefix("whsec_"))
    signed_content = "#{svix_id}.#{timestamp}.#{payload}"
    signature = Base64.strict_encode64(OpenSSL::HMAC.digest("sha256", secret_bytes, signed_content))
    {
      "svix-id" => svix_id,
      "svix-timestamp" => timestamp.to_s,
      "svix-signature" => "v1,#{signature}",
      "CONTENT_TYPE" => "application/json"
    }
  end

  test "a correctly signed bounce with a MailboxFull sub-type records inbox_full" do
    payload = {
      type: "email.bounced",
      data: {to: [@user.email], bounce: {type: "Permanent", subType: "MailboxFull"}}
    }.to_json

    post webhooks_resend_path, params: payload, headers: signed_headers(payload)
    assert_response :success

    @user.reload
    assert_equal "inbox_full", @user.email_bounce_type
    assert_not_nil @user.email_bounced_at
  end

  test "a correctly signed bounce with no mailbox-full signal records wrong_email" do
    payload = {
      type: "email.bounced",
      data: {to: [@user.email], bounce: {type: "Permanent", subType: "NoEmail"}}
    }.to_json

    post webhooks_resend_path, params: payload, headers: signed_headers(payload)
    assert_response :success

    @user.reload
    assert_equal "wrong_email", @user.email_bounce_type
  end

  test "an incorrectly signed request is rejected and does not record a bounce" do
    payload = {type: "email.bounced", data: {to: [@user.email], bounce: {}}}.to_json
    bad_headers = signed_headers(payload).merge("svix-signature" => "v1,bogus")

    post webhooks_resend_path, params: payload, headers: bad_headers
    assert_response :unauthorized

    assert_nil @user.reload.email_bounce_type
  end

  test "an unrecognized event type is accepted but does not record a bounce" do
    payload = {type: "email.delivered", data: {to: [@user.email]}}.to_json

    post webhooks_resend_path, params: payload, headers: signed_headers(payload)
    assert_response :success
    assert_nil @user.reload.email_bounce_type
  end

  test "a bounce for an email with no matching user does not raise" do
    payload = {type: "email.bounced", data: {to: ["nobody-here@example.com"], bounce: {}}}.to_json

    post webhooks_resend_path, params: payload, headers: signed_headers(payload)
    assert_response :success
  end
end
