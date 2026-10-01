# frozen_string_literal: true

# Serves localized, static legal pages (Terms + Privacy). Content is loaded
# from authored HTML under docs/legal/ and is noindex so the funnel stays out of
# search engines.
class LegalController < ApplicationController
  allow_unauthenticated_access
  layout "beta"

  # Where the legal page can send someone back to. The person who taps the
  # privacy notice on the registration screen must land back on the
  # registration screen with their input intact, not be dumped on step 1.
  # Turbo restores the cached copy of that screen, so the typed values survive.
  RETURN_STEPS = {
    "consent" => :beta_consent_path,
    "register" => :beta_register_path
  }.freeze

  around_action :with_beta_locale
  before_action :set_noindex

  def show
    @content = Legal::Content.find(type: params[:type], locale: I18n.locale.to_s)
    @return_url = return_url_for(params[:from])
  end

  private

  def return_url_for(step)
    path_helper = RETURN_STEPS[step.to_s] || :beta_consent_path
    public_send(path_helper, locale: params[:locale])
  end

  # An explicit ?locale= wins and is remembered for the rest of the funnel, so
  # following a link from /beta keeps the language the person chose. German is
  # the fallback for the legal pages. `with_locale` keeps the choice scoped to
  # this request instead of leaking to the next one on the same thread.
  def with_beta_locale(&action)
    session[:beta_locale] = locale_param if locale_param
    I18n.with_locale(session[:beta_locale] || :de, &action)
  end

  def locale_param
    @locale_param ||= begin
      requested = params[:locale].to_s.downcase
      Legal::Content::LANGUAGES.include?(requested) ? requested : nil
    end
  end
end
