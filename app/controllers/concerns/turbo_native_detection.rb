module TurboNativeDetection
  extend ActiveSupport::Concern

  included do
    before_action :detect_turbo_native
    helper_method :turbo_native_app?
  end

  private

  def detect_turbo_native
    return unless turbo_native_app?

    request.variant = :turbo_native
    authenticate_native_token if request.headers["X-Turbo-Native-Token"].present?
  end

  def _layout
    if turbo_native_app? && lookup_context.exists?("turbo_native", "layouts")
      "turbo_native"
    else
      super
    end
  end

  def authenticate_native_token
    token = request.headers["X-Turbo-Native-Token"] || cookies[:native_auth_token]
    user = User.find_by(native_auth_token: token)
    Current.user ||= user if user&.valid_native_auth_token?
  end

  def turbo_native_app?
    request.headers["HTTP_X_HOTWIRE_NATIVE"].present? ||
      request.user_agent&.include?("Turbo Native") ||
      request.user_agent&.include?("Ruby Native")
  end
end
