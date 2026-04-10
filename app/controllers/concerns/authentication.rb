module Authentication
  extend ActiveSupport::Concern

  VALID_SESSION_DAYS = 7

  included do
    helper_method :authenticated?
    before_action :authenticate_user, unless: :devise_controller?
  end

  class_methods do
    def allow_unauthenticated_access(**)
      skip_before_action(:authenticate_user, **)
    end

    def devise_controller?
      false
    end
  end

  private

  def authenticate_user
    return if authenticated?

    store_location_for(:user, request.fullpath) if request.get? || request.head?
    redirect_to new_session_path
  end

  def login(user)
    reset_session
    session[:user_id] = user.id
    cookies.encrypted[:user_id] = {
      value: user.id,
      expires: VALID_SESSION_DAYS.days.from_now,
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

  def redirect_if_authenticated
    return unless authenticated?

    redirect_to user_root_path
  end

  def after_sign_in_path
    step = current_user.first_incomplete_onboarding_step
    step ? onboarding_path(step) : user_root_path
  end

  def require_onboarding_completed
    return unless authenticated?

    step = current_user.first_incomplete_onboarding_step
    redirect_to onboarding_path(step) if step
  end

  def store_location_for(resource, location)
    session["#{resource}_return_to"] = location if location.present?
  end
end
