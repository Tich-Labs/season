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
    # Survives logout (unlike the user_id cookie below) so the welcome screen can
    # tell a returning device from a genuinely new one and show Login as the
    # primary action instead of Create Account.
    cookies.permanent[:known_device] = "1"
    cookies.encrypted.permanent[:user_id] = {
      value: user.id,
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
    Current.user ||= User.find_by(id: session[:user_id] || cookies.encrypted[:user_id])
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
