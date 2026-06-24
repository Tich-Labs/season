class ApplicationController < ActionController::Base
  include Authentication

  before_action :set_locale, if: :current_user

  private

  def set_locale
    I18n.locale = current_user.language.to_sym if current_user.language.present?
  end
end
