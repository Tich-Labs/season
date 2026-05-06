class Settings::LanguageController < ApplicationController
  layout "launch"

  def show
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(language: params[:user][:language])
      I18n.locale = @user.language.to_sym
      redirect_to language_settings_path, notice: t("settings.language.updated")
    else
      render :show, status: :unprocessable_content
    end
  end
end
