class Admin::SessionsController < ApplicationController
  layout "admin_auth"
  allow_unauthenticated_access only: [:new, :create]
  skip_onboarding_requirement only: [:new, :create, :destroy]

  def new
    redirect_to admin_root_path if authenticated? && current_user&.admin?
  end

  def create
    user = User.find_by(email: params[:email]&.downcase&.strip)

    if user&.valid_password?(params[:password]) && user.admin?
      login(user)
      redirect_to admin_root_path
    else
      @error = true
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    logout
    redirect_to admin_login_path
  end
end
