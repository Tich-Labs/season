class ConsentController < ApplicationController
  layout "application"

  def show
    @consent_types = UserConsent::VALID_CONSENT_TYPES
  end

  def create
    consent_types = params[:consents]&.keys || []

    %w[health_data_processing symptom_tracking cycle_tracking menstrual_data].each do |type|
      if consent_types.include?(type)
        current_user.user_consents.find_or_initialize_by(consent_type: type).grant!(
          request.remote_ip,
          request.user_agent
        )
      end
    end

    redirect_to user_root_path, notice: t(".saved")
  end

  def destroy
    consent_type = params[:id]
    consent = current_user.user_consents.active.find_by(consent_type: consent_type)
    consent&.revoke!(request.remote_ip, request.user_agent)

    redirect_to consent_settings_path, notice: t(".revoked")
  end
end
