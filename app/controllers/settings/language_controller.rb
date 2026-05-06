class Settings::LanguageController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(language: params[:user][:language])
      I18n.locale = @user.language.to_sym
      redirect_to settings_language_path, notice: t("settings.language.updated")
    else
      render :show, status: :unprocessable_content
    end
  end
end
