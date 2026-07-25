class SessionsController < ApplicationController
  layout "launch"
  allow_unauthenticated_access only: [:new, :create, :user_status, :pin_login]
  skip_onboarding_requirement
  before_action :redirect_if_authenticated, only: [:new, :create]

  rate_limit to: 5, within: 15.minutes, only: [:create, :pin_login], with: -> { rate_limited }, if: -> { !Rails.env.development? }

  def new
    @user = User.new
  end

  def create
    email = params[:email].to_s.strip.downcase
    @user = User.find_by(email: email)

    if @user&.valid_password?(params[:password])
      unless @user.confirmed?
        @error_type = :unconfirmed
        @user = User.new
        render :new, status: :unprocessable_content
        return
      end
      login @user
      cookies.permanent[:season_email] = {value: @user.email, httponly: false}
      redirect_to after_sign_in_path
    else
      @error_type = email.present? ? :wrong_password : :wrong_email
      @user = User.new
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    logout
    cookies.delete(:season_email)
    cookies[:clear_email] = {value: "1", httponly: false}
    redirect_to root_path
  end

  # GET /sessions/user_status?email=... — check if user has PIN set
  def user_status
    email = params[:email].to_s.strip.downcase
    user = User.find_by(email: email)
    if user
      render json: {has_pin: user.pin_set?, email: user.email}
    else
      render json: {has_pin: false, email: nil}
    end
  end

  # POST /sessions/pin_login — authenticate with PIN instead of password
  def pin_login
    email = params[:email].to_s.strip.downcase
    @user = User.find_by(email: email)

    if @user&.authenticate_pin(params[:pin])
      login @user
      cookies.permanent[:season_email] = {value: @user.email, httponly: false}
      render json: {success: true, redirect: after_sign_in_path}
    else
      render json: {success: false, error: "Wrong PIN. Please try again."}, status: :unauthorized
    end
  end

  private

  def rate_limited
    if request.format.json?
      render json: {success: false, error: "Too many attempts. Please wait 15 minutes."}, status: :too_many_requests
    else
      flash.now[:alert] = t(".too_many_attempts")
      render :new, status: :too_many_requests
    end
  end
end
