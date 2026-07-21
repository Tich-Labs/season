class Settings::LanguageController < ApplicationController
  def show
    @user = current_user
  end

  def update
    @user = current_user
    new_language = params.dig(:user, :language)

    unless new_language.present? && new_language.to_sym.in?(I18n.available_locales)
      redirect_to edit_settings_path, alert: t("settings.language.invalid")
      return
    end

    if @user.update(language: new_language)
      I18n.locale = new_language.to_sym
      redirect_to edit_settings_path, notice: t("settings.language.updated")
    else
      redirect_to edit_settings_path, alert: t("settings.language.error")
    end
  end
end
