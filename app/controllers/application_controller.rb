class ApplicationController < ActionController::Base
  include Authentication
  include PinProtection

  before_action :set_locale

  private

  def set_locale
    I18n.locale = resolve_locale
  end

  def resolve_locale
    if current_user&.language.present?
      current_user.language.to_sym
    elsif session[:locale].present? && session[:locale].to_sym.in?(I18n.available_locales)
      session[:locale].to_sym
    else
      locale_from_accept_language_header || I18n.default_locale
    end.tap { |locale| session[:locale] = locale.to_s }
  end

  def locale_from_accept_language_header
    header = request.headers["Accept-Language"]
    return if header.blank?

    header.split(",").each do |part|
      code = part.split(";").first.to_s.strip
      next if code.blank?

      locale = code.split("-").first.downcase.to_sym
      return locale if locale.in?(I18n.available_locales)
    end
    nil
  end
end
