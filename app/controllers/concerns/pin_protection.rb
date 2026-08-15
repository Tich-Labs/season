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

  # Called from anywhere that just proved the user's identity strongly enough
  # to also satisfy the PIN check: a fresh login (password, PIN quick-login,
  # or OAuth), entering the PIN itself, or WebAuthn. Shared so PIN_TIMEOUT
  # and the timestamp format it's compared against only live in one place.
  def mark_pin_verified!
    session[:pin_verified_at] = Time.current.to_i
  end
end
