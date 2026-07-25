require "test_helper"

class WebauthnControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
    @alice.set_pin("1234")
    @credential = @alice.webauthn_credentials.create!(
      credential_id: "test-credential-id-abc123",
      public_key: "test-public-key",
      label: "Test Face ID",
      sign_count: 0
    )
    sign_in_as(@alice)
  end

  test "WebAuthn authenticate sets pin_verified_at, next request passes guard 3" do
    get edit_settings_path
    assert_response :success
    assert_includes response.body, "pin-unlock-modal"

    get webauthn_authentication_challenge_path
    assert_response :success

    post webauthn_authenticate_path, params: {
      credential: {id: @credential.credential_id}
    }
    assert_response :success
    json = response.parsed_body
    assert json["success"]

    get edit_settings_path
    assert_response :success
    assert_not_includes response.body, "pin-unlock-modal"
  end
end
