module ConsentCheck
  extend ActiveSupport::Concern

  included do
    before_action :check_health_consent, if: :authenticated?
  end

  private

  def check_health_consent
    return if current_user.health_consent?

    consent_path = "/settings/consent"
    account_path = "/account"
    return if request.fullpath == consent_path || request.fullpath == account_path

    redirect_to consent_settings_path, alert: t("consents.required") unless performed?
  end

  def consent_settings_path
    "/settings/consent"
  end

  def record_consent!(consent_type)
    consent = current_user.user_consents.find_or_initialize_by(consent_type: consent_type)
    consent.grant!(
      request.remote_ip,
      request.user_agent
    )
  end
end
