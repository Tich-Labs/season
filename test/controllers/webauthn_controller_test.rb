require "test_helper"
require "webauthn/fake_client"

class WebauthnControllerTest < ActionDispatch::IntegrationTest
  # Matches the default host Rails integration tests run against
  # (request.base_url), which the controller's relying_party is built from.
  ORIGIN = "http://www.example.com"

  def setup
    @alice = users(:alice)
    @alice.set_pin("1234")
    sign_in_as(@alice)
  end

  test "GET registration-challenge returns valid WebAuthn creation options" do
    get webauthn_registration_challenge_path
    assert_response :success

    json = response.parsed_body
    assert json["challenge"].present?
    assert_equal "Season", json["rp"]["name"]
    assert_equal "public-key", json["pubKeyCredParams"].first["type"]
    assert_equal "platform", json["authenticatorSelection"]["authenticatorAttachment"]
  end

  test "full registration verifies the attestation and stores the real credential" do
    fake_client = WebAuthn::FakeClient.new(ORIGIN)

    get webauthn_registration_challenge_path
    options = response.parsed_body

    assert_difference("@alice.webauthn_credentials.count", 1) do
      post webauthn_register_path, params: {
        credential: fake_client.create(challenge: options["challenge"]),
        label: "Face ID"
      }
    end
    assert_response :success
    assert response.parsed_body["success"]

    credential = @alice.webauthn_credentials.last
    assert_equal "Face ID", credential.label
    assert_equal 0, credential.sign_count
    assert credential.public_key.present?
    assert credential.credential_id.present?
  end

  test "registration rejects an attestation signed for a different origin" do
    fake_client = WebAuthn::FakeClient.new("http://attacker.example.com")

    get webauthn_registration_challenge_path
    options = response.parsed_body

    assert_no_difference("WebauthnCredential.count") do
      post webauthn_register_path, params: {credential: fake_client.create(challenge: options["challenge"])}
    end
    assert_response :unprocessable_entity
    assert_equal "Verification failed", response.parsed_body["error"]
  end

  test "registration rejects a replayed/stale challenge" do
    fake_client = WebAuthn::FakeClient.new(ORIGIN)

    get webauthn_registration_challenge_path
    stale_options = response.parsed_body
    stale_response = fake_client.create(challenge: stale_options["challenge"])

    # A second challenge is issued (e.g. the user reloaded the page) before
    # the first attestation is ever submitted — the stale one must not verify.
    get webauthn_registration_challenge_path
    assert_response :success

    assert_no_difference("WebauthnCredential.count") do
      post webauthn_register_path, params: {credential: stale_response}
    end
    assert_response :unprocessable_entity
  end

  test "full authentication verifies the signed assertion, advances sign_count, and unlocks PIN" do
    fake_client = WebAuthn::FakeClient.new(ORIGIN)

    get webauthn_registration_challenge_path
    reg_options = response.parsed_body
    post webauthn_register_path, params: {credential: fake_client.create(challenge: reg_options["challenge"])}
    assert_response :success
    credential = @alice.webauthn_credentials.last

    travel_past_pin_grace do
      get edit_settings_path
      assert_includes response.body, "pin-unlock-modal"

      get webauthn_authentication_challenge_path
      assert_response :success
      auth_options = response.parsed_body

      post webauthn_authenticate_path, params: {
        credential: fake_client.get(challenge: auth_options["challenge"], allow_credentials: [credential.credential_id])
      }
      assert_response :success
      assert response.parsed_body["success"]
      assert_equal 1, credential.reload.sign_count

      get edit_settings_path
      assert_response :success
      assert_not_includes response.body, "pin-unlock-modal"
    end
  end

  test "authentication rejects an assertion from a different, unregistered key pair" do
    real_client = WebAuthn::FakeClient.new(ORIGIN)
    get webauthn_registration_challenge_path
    reg_options = response.parsed_body
    post webauthn_register_path, params: {credential: real_client.create(challenge: reg_options["challenge"])}
    credential = @alice.webauthn_credentials.last

    # An assertion the forger's own authenticator legitimately signed for
    # itself, over the *victim's* challenge — then relabeled with the
    # victim's credential id. `authenticatorData`/`signature` are real, just
    # signed by the wrong key. This is exactly the gap the old implementation
    # had: it only checked that a row with this credential_id existed, never
    # that the caller could prove possession of the matching private key.
    forger = WebAuthn::FakeClient.new(ORIGIN)
    get webauthn_registration_challenge_path
    forger.create(challenge: response.parsed_body["challenge"]) # gives the forger's authenticator its own credential to sign with

    get webauthn_authentication_challenge_path
    auth_options = response.parsed_body
    forged = forger.get(challenge: auth_options["challenge"])
    forged["id"] = credential.credential_id
    forged["rawId"] = credential.credential_id

    post webauthn_authenticate_path, params: {credential: forged}
    assert_response :unprocessable_entity
    assert_equal "Verification failed", response.parsed_body["error"]
    assert_equal 0, credential.reload.sign_count
  end

  test "authentication rejects a replayed assertion (sign_count not advancing)" do
    fake_client = WebAuthn::FakeClient.new(ORIGIN)
    get webauthn_registration_challenge_path
    reg_options = response.parsed_body
    post webauthn_register_path, params: {credential: fake_client.create(challenge: reg_options["challenge"])}
    credential = @alice.webauthn_credentials.last

    get webauthn_authentication_challenge_path
    auth_options = response.parsed_body
    replayed_assertion = fake_client.get(challenge: auth_options["challenge"], allow_credentials: [credential.credential_id])

    post webauthn_authenticate_path, params: {credential: replayed_assertion}
    assert_response :success
    assert_equal 1, credential.reload.sign_count

    # Same signed assertion, submitted again against a fresh challenge issued
    # for it — a cloned/replayed authenticator would report the same
    # (or lower) sign_count as before, which must be rejected.
    get webauthn_authentication_challenge_path
    post webauthn_authenticate_path, params: {credential: replayed_assertion}
    assert_response :unprocessable_entity
    assert_equal 1, credential.reload.sign_count
  end

  test "authentication returns 404 when the user has no credentials" do
    @alice.webauthn_credentials.destroy_all
    get webauthn_authentication_challenge_path
    assert_response :not_found
  end

  test "DELETE removes a credential" do
    credential = @alice.webauthn_credentials.create!(
      credential_id: "cred-1", public_key: "pk-1", sign_count: 0
    )
    assert_difference("WebauthnCredential.count", -1) do
      delete "/webauthn/credentials/#{credential.id}"
    end
    assert_response :no_content
  end

  test "cannot delete another user's credential" do
    bob_credential = users(:bob).webauthn_credentials.create!(
      credential_id: "bob-cred", public_key: "pk-bob", sign_count: 0
    )
    assert_no_difference("WebauthnCredential.count") do
      delete "/webauthn/credentials/#{bob_credential.id}"
    end
    assert_response :not_found
  end
end
