module PinProtection
  extend ActiveSupport::Concern

  PIN_TIMEOUT = 5.minutes

  included do
    before_action :require_pin_unlock
  end

  private

  def require_pin_unlock
    return unless authenticated?
    return unless current_user.pin_set?
    return if session[:pin_verified_at] && session[:pin_verified_at] > PIN_TIMEOUT.ago.to_i

    session[:return_to_after_unlock] = request.fullpath if request.get?
    redirect_to pin_unlock_path
  end

  def allow_pin_bypass
    skip_before_action :require_pin_unlock
  end
end
