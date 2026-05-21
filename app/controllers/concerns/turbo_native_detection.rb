module TurboNativeDetection
  extend ActiveSupport::Concern

  included do
    helper_method :turbo_native_app?
    before_action :authenticate_via_token, if: :turbo_native_app?
  end

  private

  def authenticate_via_token
    token = request.headers["X-Turbo-Native-Token"]
    user = User.find_by(native_auth_token: token)

    if user&.native_auth_token_valid?
      Current.user = user
      session[:user_id] = user.id
    elsif request.format.json?
      render json: { error: "Unauthorized" }, status: :unauthorized
    else
      redirect_to new_session_path
    end
  end

  def turbo_native_app?
    request.user_agent&.match?(/Turbo Native|Season iOS/i)
  end

  def respond_with_token(user)
    {
      turbo_native_token: user.native_auth_token,
      user: { id: user.id, email: user.email, name: user.name }
    }
  end
end
