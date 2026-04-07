require "ostruct"

class SettingsController < ApplicationController
  # include Authentication # TEMP: disabled for dev
  # before_action :require_onboarding_completed

  def edit
    @user = current_user || OpenStruct.new(
      name: "Demo User",
      email: "demo@season.app",
      cycle_length: 28,
      period_length: 5,
      contraception_type: nil
    )
  end

  def update
    @user = current_user
    if @user&.update(user_params)
      redirect_to edit_settings_path, notice: "Settings saved"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :language, :cycle_length, :period_length, :contraception_type, :life_stage)
  end
end
