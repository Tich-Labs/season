class SessionsController < ApplicationController
  layout "launch"
  allow_unauthenticated_access only: [:new, :create]
  skip_onboarding_requirement
  before_action :redirect_if_authenticated, only: [:new, :create]

  rate_limit to: 5, within: 15.minutes, only: :create, with: -> { rate_limited }, if: -> { !Rails.env.development? }

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
      redirect_to after_sign_in_path
    else
      @error_type = email.present? ? :wrong_password : :wrong_email
      @user = User.new
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    logout
    redirect_to root_path
  end

  private

  def rate_limited
    flash.now[:alert] = t(".too_many_attempts")
    render :new, status: :too_many_requests
  end
end
