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
    attributes = user_params.to_h.symbolize_keys
    email = attributes[:email].to_s.downcase

    if User.exists?(email: email)
      @error_type = :already_registered
      @user = User.new(attributes)
      render :new, status: :unprocessable_content
    else
      @user = User.new(attributes.merge(email: email))

      if @user.save
        login @user
        redirect_to onboarding_path(1)
      else
        render :new, status: :unprocessable_content
      end
    end
  end

  private

  def user_params
    if params[:user].present?
      params.expect(user: [:email, :password, :password_confirmation])
    else
      params.permit(:email, :password, :password_confirmation)
    end
  end
end
