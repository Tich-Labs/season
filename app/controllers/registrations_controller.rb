class RegistrationsController < ApplicationController
  layout "launch"

  allow_unauthenticated_access only: [:new, :create]
  skip_onboarding_requirement

  def new
    @user = User.new
    @invite_token = params[:invite_token]
    @error_type = params[:error]
  end

  def create
    attributes = user_params.to_h.symbolize_keys
    email = attributes[:email].to_s.downcase
    name = attributes[:name].presence || email.split("@").first

    if User.exists?(email: email)
      @error_type = :already_registered
      @user = User.new(attributes)
      render :new, status: :unprocessable_content
    else
      @user = User.new(attributes.merge(email: email, name: name))
      @user.skip_confirmation!

      if @user.save
        login @user
        redirect_to after_sign_in_path
      else
        render :new, status: :unprocessable_content
      end
    end
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation, :name)
  end
end
