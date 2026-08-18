module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :authenticated?, :returning_user?
    before_action :authenticate_user, unless: :devise_controller?
    before_action :require_onboarding_completed, if: :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**)
      skip_before_action(:authenticate_user, **)
    end

    def skip_onboarding_requirement(**)
      skip_before_action(:require_onboarding_completed, **)
    end
  end

  private

  def authenticate_user
    return if authenticated?

    redirect_to native_app? ? root_path : new_session_path
  end

  # Persistent until logout, on web and native alike — no time-based expiry.
  def login(user)
    reset_session
    session[:user_id] = user.id
    # A fresh login (password, PIN quick-login, or OAuth) already proves who
    # this is, so it counts as a fresh PIN unlock too — reset_session above
    # just wiped pin_verified_at, and without this the PIN modal would demand
    # a *second* proof of identity seconds after the first. The 5-minute
    # backgrounding/tab-switch timeout (PinProtection::PIN_TIMEOUT) still
    # applies from here exactly as before.
    mark_pin_verified!
    # Survives logout (unlike the user_id cookie below) so the welcome screen can
    # tell a returning device from a genuinely new one and show Login as the
    # primary action instead of Create Account.
    cookies.permanent[:known_device] = "1"
    # pf (password fingerprint) ties this cookie to the password hash at
    # issue time, so a password change invalidates it wherever it's stored —
    # see User#password_fingerprint and current_user's cookie branch below.
    cookies.encrypted.permanent[:user_id] = {
      value: {id: user.id, pf: user.password_fingerprint},
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax
    }
    Current.user = user
  end

  def logout
    reset_session
    cookies.delete(:user_id)
    Current.user = nil
  end

  def current_user
    Current.user ||= session[:user_id] ? User.find_by(id: session[:user_id]) : user_from_remember_cookie
  end

  # Falls back to the persistent cookie once the session cookie is gone
  # (expired, or never set — e.g. a native app relaunch). Requires the
  # embedded password fingerprint to still match the user's current
  # encrypted_password: a device that's lost/stolen with no live session
  # left, only this cookie, gets signed out the moment the password is
  # changed anywhere, instead of staying persistently authenticated forever
  # with no way to revoke it. A cookie from before this fingerprint existed
  # decodes to something other than a Hash and is simply treated as absent —
  # that device just needs to log in again once, same as an invalid cookie.
  def user_from_remember_cookie
    data = cookies.encrypted[:user_id]
    return nil unless data.is_a?(Hash)

    user = User.find_by(id: data["id"])
    return nil unless user

    user if ActiveSupport::SecurityUtils.secure_compare(user.password_fingerprint, data["pf"].to_s)
  end

  def authenticated?
    current_user.present?
  end

  def returning_user?
    cookies[:known_device].present?
  end

  def redirect_if_authenticated
    return unless authenticated?

    redirect_to user_root_path
  end

  # Always the monthly calendar — deliberately ignores any deep link the user
  # was trying to reach before being asked to log in.
  def after_sign_in_path
    step = current_user.next_onboarding_step
    return onboarding_path(step) if step

    user_root_path
  end

  def require_onboarding_completed
    step = current_user.first_incomplete_onboarding_step
    redirect_to onboarding_path(step) if step
  end
end
