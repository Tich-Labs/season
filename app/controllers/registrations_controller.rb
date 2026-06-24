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

    unless params[:terms_accepted] == "1"
      @user = User.new(user_params)
      @error_type = :terms_not_accepted
      render :new, status: :unprocessable_content
      return
    end

    if User.exists?(email: email)
      @error_type = :already_registered
      @user = User.new(user_params)
      render :new, status: :unprocessable_content
    else
      @user = User.new(user_params.merge(email: email, name: name))
      @user.skip_confirmation! if native_app?

      if @user.save
        if native_app?
          login(@user)
          redirect_to after_sign_in_path
        else
          redirect_to check_email_registration_path
        end
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
