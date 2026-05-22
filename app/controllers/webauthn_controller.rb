class WebauthnController < ApplicationController
  allow_pin_bypass

  def registration_challenge
    challenge = SecureRandom.random_bytes(32)
    session[:webauthn_challenge] = Base64.urlsafe_encode64(challenge)
    session[:webauthn_challenge_created_at] = Time.current.to_i

    user_id = Base64.urlsafe_encode64(current_user.id.to_s)

    render json: {
      challenge: session[:webauthn_challenge],
      rp: {name: "Season", id: request.host},
      user: {
        id: user_id,
        name: current_user.email,
        displayName: current_user.first_name
      },
      pubKeyCredParams: [{type: "public-key", alg: -7}],
      authenticatorSelection: {
        authenticatorAttachment: "platform",
        userVerification: "required"
      },
      attestation: "none"
    }
  end

  def register
    challenge = session[:webauthn_challenge]
    session[:webauthn_challenge] = nil

    unless challenge.present? && params[:credential].present?
      return render json: {error: "Invalid registration"}, status: :unprocessable_content
    end

    cred = params[:credential]
    existing = current_user.webauthn_credentials.create(
      credential_id: cred[:id],
      public_key: cred[:response][:publicKey],
      label: params[:label] || "Default",
      sign_count: 0
    )

    if existing.persisted?
      render json: {success: true}
    else
      render json: {error: existing.errors.full_messages}, status: :unprocessable_content
    end
  end

  def authentication_challenge
    return render json: {error: "No credentials"}, status: :not_found unless current_user.webauthn_credentials.any?

    challenge = SecureRandom.random_bytes(32)
    session[:webauthn_challenge] = Base64.urlsafe_encode64(challenge)
    session[:webauthn_challenge_created_at] = Time.current.to_i

    credentials = current_user.webauthn_credentials.map do |cred|
      {
        id: cred.credential_id,
        type: "public-key"
      }
    end

    render json: {
      challenge: session[:webauthn_challenge],
      allowCredentials: credentials,
      userVerification: "required",
      timeout: 60000
    }
  end

  def authenticate
    challenge = session[:webauthn_challenge]
    session[:webauthn_challenge] = nil

    unless challenge.present? && params[:credential].present?
      return render json: {error: "Invalid authentication"}, status: :unprocessable_content
    end

    credential = current_user.webauthn_credentials.find_by(credential_id: params[:credential][:id])
    unless credential
      return render json: {error: "Credential not found"}, status: :not_found
    end

    session[:pin_verified_at] = Time.current.to_i
    render json: {success: true, redirect: session.delete(:return_to_after_unlock) || user_root_path}
  end

  def destroy
    credential = current_user.webauthn_credentials.find(params[:id])
    credential.destroy
    head :no_content
  end
end
