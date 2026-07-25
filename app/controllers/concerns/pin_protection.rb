module PinProtection
  extend ActiveSupport::Concern

  PIN_TIMEOUT = 5.minutes

  included do
    before_action :require_pin_unlock
  end

  class_methods do
    def allow_pin_bypass(**options)
      skip_before_action :require_pin_unlock, **options
    end
  end

  private

  def require_pin_unlock
    return unless authenticated?
    return unless current_user.pin_set?
    return if session[:pin_verified_at] && session[:pin_verified_at] > PIN_TIMEOUT.ago.to_i

    @pin_unlock_required = true
    session[:return_to_after_unlock] = request.fullpath if request.get? || request.head?
  end
end
