class OmniauthController < ApplicationController
  allow_unauthenticated_access only: [:callback, :failure]
  skip_onboarding_requirement
  skip_before_action :verify_authenticity_token, only: [:callback]

  def callback
    handle_oauth(normalize_provider(params[:provider]))
  end

  def failure
    redirect_to new_session_path, alert: I18n.t("oauth.errors.authentication_failed")
  end

  private

  def normalize_provider(provider)
    (provider == "google_oauth2") ? "google" : provider
  end

  def handle_oauth(provider_name)
    auth = request.env["omniauth.auth"]

    unless auth
      redirect_to new_session_path, alert: I18n.t("oauth.errors.authentication_failed")
      return
    end

    email = auth.dig("info", "email") || auth.dig("extra", "raw_info", "email")

    if email.blank?
      redirect_to new_session_path, alert: I18n.t("oauth.errors.email_required", provider: provider_name.to_s.titleize)
      return
    end

    user = User.find_or_create_from_oauth(provider_name, auth)

    if user.persisted?
      login user
      redirect_to after_sign_in_path
    else
      redirect_to new_session_path, alert: I18n.t("oauth.errors.creation_failed")
    end
  end
end
