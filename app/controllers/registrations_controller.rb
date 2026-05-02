class RegistrationsController < ApplicationController
  layout "launch"

  allow_unauthenticated_access only: [:new, :create, :check_email]
  skip_onboarding_requirement
  before_action :redirect_if_authenticated, only: [:new, :create]

  def new
    @user = User.new
    @invite_token = params[:invite_token]
    @error_type = params[:error]
  end

  def create
    email = user_params[:email].to_s.downcase
    name = user_params[:name].presence || email.split("@").first

    if User.exists?(email: email)
      @error_type = :already_registered
      @user = User.new(user_params)
      render :new, status: :unprocessable_content
    else
      @user = User.new(user_params.merge(email: email, name: name))

      if @user.save
        redirect_to check_email_registration_path
      else
        render :new, status: :unprocessable_content
      end
    end
  end

  def check_email
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation, :name)
  end
end
