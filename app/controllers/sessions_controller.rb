class SessionsController < ApplicationController
  include Authentication

  allow_unauthenticated_access only: [ :new, :create ]
  before_action :redirect_if_authenticated, only: [ :new, :create ]
  before_action :rate_limit_login, only: [ :create ]

  LOGIN_RATE_LIMIT = 5
  LOGIN_RATE_WINDOW = 15.minutes

  def new
    @user = User.new
  end

  def create
    email = params[:email]
    password = params[:password]

    @user = User.find_by(email: email.downcase)

    if @user&.valid_password?(password)
      reset_login_attempts
      login @user
      redirect_to after_sign_in_path
    else
      increment_login_attempts
      @error_type = email.present? ? :wrong_password : :wrong_email
      @user = User.new
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout
    redirect_to root_path
  end

  def form_session_params
    params.fetch(:user, {}).permit(:email, :password)
  end

  private

  def determine_error_type
    email = form_session_params[:email]
    form_session_params[:password]

    if email.blank?
      :wrong_email
    elsif User.exists?(email: email.downcase)
      :wrong_password
    else
      :wrong_email
    end
  end

  def rate_limit_login
    return unless too_many_login_attempts?

    flash.now[:alert] = "Too many login attempts. Please try again later."
    render :new, status: :too_many_requests
  end

  def too_many_login_attempts?
    login_attempts >= LOGIN_RATE_LIMIT
  end

  def login_attempts
    Rails.cache.read(login_attempts_key) || 0
  end

  def increment_login_attempts
    key = login_attempts_key
    attempts = login_attempts + 1
    Rails.cache.write(key, attempts, expires_in: LOGIN_RATE_WINDOW)
  end

  def reset_login_attempts
    Rails.cache.delete(login_attempts_key)
  end

  def login_attempts_key
    "login_attempts/#{request.ip}"
  end
end
