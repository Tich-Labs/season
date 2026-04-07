class OmniauthController < ApplicationController
  include Authentication

  allow_unauthenticated_access only: [:callback, :failure]
  skip_before_action :verify_authenticity_token, only: [:callback]

  def callback
    provider = request.path.split("/").second
    normalized_provider = normalize_provider(provider)
    handle_oauth(normalized_provider)
  end

  def failure
    redirect_to new_session_path, alert: I18n.t("oauth.errors.authentication_failed")
  end

  private

  def normalize_provider(provider)
    case provider
    when "google_oauth2" then "google"
    when "facebook" then "facebook"
    when "apple" then "apple"
    else provider
    end
  end

  def handle_oauth(provider_name)
    auth = request.env["omniauth.auth"]

    if auth
      email = auth.dig("info", "email") ||
        auth.dig("extra", "raw_info", "email")

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
    else
      redirect_to new_session_path, alert: I18n.t("oauth.errors.authentication_failed")
    end
  end
end
