class RegistrationsController < ApplicationController
  include Authentication
  layout "launch"

  allow_unauthenticated_access only: [:new, :create]
  skip_before_action :authenticate_user, only: [:new, :create]

  def new
    @user = User.new
    @invite_token = params[:invite_token]
    @error_type = params[:error]
  end

  def create
    email = params[:email]

    if User.exists?(email: email.downcase)
      @error_type = :already_registered
      @user = User.new
      render :new
    else
      @user = User.new(
        email: params[:email],
        password: params[:password],
        password_confirmation: params[:password_confirmation]
      )

      if @user.save
        login @user
        redirect_to onboarding_path(1)
      else
        render :new
      end
    end
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end
end
