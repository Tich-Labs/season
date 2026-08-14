class ApplicationController < ActionController::Base
  include Authentication
  include PinProtection

  before_action :set_locale
  helper_method :safe_back_path

  private

  # For "back" links on pages reachable from more than one place — a hardcoded
  # destination is only ever right for one of them. Falls back to `fallback`
  # when there's no referer, and never returns anywhere off this app's own
  # origin (a spoofed/cross-site Referer header can't turn this into an open
  # redirect).
  #
  # `allowed`, when given, restricts which referers get trusted at all —
  # without it, two pages that both call safe_back_path and link to each
  # other (e.g. A's only entry point is B, but B's back link trusts *any*
  # referer) ping-pong forever: leaving B for A, then A back to B, makes B's
  # own referer become A, so B's "back" now points at A instead of B's real
  # parent. Pass the page's actual known entry points to break that.
  def safe_back_path(fallback, allowed: nil)
    referer = request.referer
    return fallback if referer.blank?

    uri = URI.parse(referer)
    return fallback unless uri.host == request.host

    path = uri.path.presence
    return fallback if path.blank?
    return fallback if allowed&.none?(path)

    path
  rescue URI::InvalidURIError
    fallback
  end

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
