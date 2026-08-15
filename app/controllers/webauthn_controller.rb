class WebauthnController < ApplicationController
  # Only the actions that verify an *existing* credential may run while
  # PIN-locked — that's the whole point of WebAuthn as a PIN alternative.
  # Registering a brand-new credential must NOT be reachable from a
  # PIN-locked session (stolen/borrowed device, leaked session cookie):
  # otherwise that session could enroll its own credential and immediately
  # "authenticate" with it, bypassing the PIN entirely. A new credential can
  # only be added by a session that is already fully unlocked.
  allow_pin_bypass only: [:authentication_challenge, :authenticate]

  rescue_from WebAuthn::Error do |e|
    Rails.logger.warn "[WebAuthn] #{e.class}: #{e.message}"
    render json: {error: "Verification failed"}, status: :unprocessable_content
  end

  rescue_from ActiveRecord::RecordNotFound do
    render json: {error: "Credential not found"}, status: :not_found
  end

  def registration_challenge
    options = relying_party.options_for_registration(
      user: {
        # An opaque byte handle, not the id itself — base64url-encoded so the
        # client can decode it straight into the ArrayBuffer the browser API
        # requires, same as the challenge and every credential id below.
        id: Base64.urlsafe_encode64(current_user.id.to_s),
        name: current_user.email,
        display_name: current_user.first_name
      },
      exclude: current_user.webauthn_credentials.pluck(:credential_id),
      authenticator_selection: {authenticator_attachment: "platform", user_verification: "required"}
    )
    session[:webauthn_challenge] = options.challenge
    render json: options
  end

  def register
    unless session[:webauthn_challenge].present? && params[:credential].present?
      return render json: {error: "Invalid registration"}, status: :unprocessable_content
    end

    webauthn_credential = relying_party.verify_registration(
      params[:credential].to_unsafe_h, session.delete(:webauthn_challenge)
    )

    credential = current_user.webauthn_credentials.create(
      credential_id: webauthn_credential.id,
      public_key: webauthn_credential.public_key,
      sign_count: webauthn_credential.sign_count,
      label: params[:label].presence || "Default"
    )

    if credential.persisted?
      render json: {success: true}
    else
      render json: {error: credential.errors.full_messages}, status: :unprocessable_content
    end
  end

  def authentication_challenge
    return render json: {error: "No credentials"}, status: :not_found unless current_user.webauthn_credentials.any?

    options = relying_party.options_for_authentication(
      allow: current_user.webauthn_credentials.pluck(:credential_id),
      user_verification: "required"
    )
    session[:webauthn_challenge] = options.challenge
    render json: options
  end

  def authenticate
    unless session[:webauthn_challenge].present? && params[:credential].present?
      return render json: {error: "Invalid authentication"}, status: :unprocessable_content
    end

    webauthn_credential, stored_credential = relying_party.verify_authentication(
      params[:credential].to_unsafe_h, session.delete(:webauthn_challenge)
    ) { |cred| current_user.webauthn_credentials.find_by!(credential_id: cred.id) }

    # The authenticator's own move-forward counter — verified above to be
    # strictly greater than what we had on file (that's what proves this
    # isn't a replayed/cloned assertion). Persist the new value or every
    # future attempt fails the same replay check against a stale number.
    stored_credential.update!(sign_count: webauthn_credential.sign_count)

    mark_pin_verified!
    render json: {success: true, redirect: session.delete(:return_to_after_unlock) || user_root_path}
  end

  def destroy
    credential = current_user.webauthn_credentials.find(params[:id])
    credential.destroy
    head :no_content
  end

  private

  # Built per-request from the actual host/origin rather than a fixed
  # initializer value, so this works whether the app is reached at the
  # canonical APP_HOST, an *.onrender.com preview, or localhost in
  # development — matching how `config.hosts` already allows more than one
  # host. A WebAuthn credential only ever verifies against the same rp_id it
  # was registered under, so this must stay derived from the request the
  # same way on both the register and authenticate paths.
  def relying_party
    @relying_party ||= WebAuthn::RelyingParty.new(
      name: "Season",
      id: request.host,
      allowed_origins: [request.base_url]
    )
  end
end
