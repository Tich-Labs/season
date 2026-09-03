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

    if session[:pin_verified_at] && session[:pin_verified_at] > PIN_TIMEOUT.ago.to_i
      # Sliding window, not a one-shot expiry: PIN_TIMEOUT is meant as an
      # *idle* timeout (see app_lock_controller.js, which only forces a
      # re-check after the tab/app was actually backgrounded past this same
      # duration) — but pin_verified_at was previously only ever written at
      # login/PIN-entry and never refreshed, so it quietly became a flat
      # "locked exactly 5 minutes after login" timer instead, regardless of
      # activity in between. That made any continuously-used flow longer
      # than 5 minutes — multi-step appointment creation (category, location,
      # guests, notes, reminder, repeat/custom-repeat sub-modals) being the
      # single most likely one — hit the PIN wall on the very next request,
      # reported as the unlock modal "randomly" appearing after saving or
      # editing an appointment. Refreshing it here on every request that
      # still passes keeps genuinely active users unlocked indefinitely,
      # while real idle time (tab backgrounded, phone locked) still expires
      # it exactly as designed.
      mark_pin_verified!
      return
    end

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
