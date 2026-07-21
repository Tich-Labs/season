module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    allow_unauthenticated_access
    skip_onboarding_requirement
    skip_before_action :verify_authenticity_token, only: [:google_oauth2, :facebook, :apple, :failure]

    def google_oauth2
      handle_oauth("google_oauth2")
    end

    def facebook
      handle_oauth("facebook")
    end

    def apple
      handle_oauth("apple")
    end

    def failure
      error = request.env["omniauth.error"]
      error_type = request.env["omniauth.error.type"]
      Rails.logger.error "[OmniAuth Failure] strategy=#{params[:strategy]&.inspect} error=#{error&.class}: #{error&.message} error_type=#{error_type&.inspect} origin=#{request.env["omniauth.origin"]&.inspect}"
      redirect_to new_session_path, alert: I18n.t("oauth.errors.authentication_failed")
    end

    private

    def handle_oauth(provider_name)
      auth = request.env["omniauth.auth"]

      unless auth
        redirect_to new_session_path, alert: I18n.t("oauth.errors.authentication_failed")
        return
      end

      email = auth.dig("info", "email") || auth.dig("extra", "raw_info", "email")
      uid = auth.uid

      # Apple only provides email on first authorization — allow UID-only lookup on repeat sign-ins
      if email.blank? && uid.blank?
        redirect_to new_session_path, alert: I18n.t("oauth.errors.email_required", provider: provider_name.to_s.titleize)
        return
      end

      user = User.find_or_create_from_oauth(provider_name, auth)

      if user.persisted?
        user.store_google_tokens!(auth) if provider_name == "google_oauth2"
        login user
        redirect_to after_sign_in_path
      else
        redirect_to new_session_path, alert: I18n.t("oauth.errors.creation_failed")
      end
    end
  end
end
