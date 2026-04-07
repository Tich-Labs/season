class InvitesController < ApplicationController
  allow_unauthenticated_access

  def show
    @user = User.find_by!(invite_token: params[:token])
    redirect_to root_path, alert: "Invalid invite" unless @user && @user.invite_accepted_at.nil?
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Invalid invite link"
  end

  def update
    @user = User.find_by!(invite_token: params[:token])
    if @user.update(
      password: params[:password],
      password_confirmation: params[:password],
      invite_accepted_at: Time.current,
      invite_token: nil
    )
      login(@user)
      redirect_to onboarding_path(1), notice: "Welcome to Season!"
    else
      render :show, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Invalid invite link"
  end
end
