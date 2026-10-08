# frozen_string_literal: true

# Public beta onboarding: three screens (consent → registration → confirmation).
# German is the default for this funnel only; English is available via the
# language toggle.
class BetaOnboardingController < ApplicationController
  allow_unauthenticated_access
  layout "beta"

  around_action :with_beta_locale
  before_action :set_noindex

  def consent
    @health_consent = session[:health_consent].present?
    @survey_opt_in = session[:survey_opt_in].present?
  end

  def create_consent
    consent_params = params.expect(consent: [:health_consent, :survey_opt_in])

    unless consent_params[:health_consent] == "1"
      redirect_to beta_consent_path(locale: locale_param) and return
    end

    session[:health_consent] = true
    session[:health_consent_at] = Time.current.iso8601
    session[:health_consent_version] = Consents::Recorder::DOC_VERSIONS["health_data"]
    session[:survey_opt_in] = consent_params[:survey_opt_in] == "1"
    session[:beta_locale] = locale_param || I18n.locale.to_s
    session[:beta_step] = 2

    redirect_to beta_register_path(locale: locale_param)
  end

  def register
    if session[:health_consent].blank?
      redirect_to beta_consent_path(locale: locale_param) and return
    end

    @form = BetaOnboarding::RegistrationForm.new
    @beta_tester = BetaTester.new
  end

  def create_register
    if session[:health_consent].blank?
      redirect_to beta_consent_path(locale: locale_param) and return
    end

    reg_params = registration_params
    @form = BetaOnboarding::RegistrationForm.new(reg_params)

    unless @form.valid?
      @beta_tester = BetaTester.new(@form.to_beta_tester_attributes)
      flash.now[:alert] = t("beta_onboarding.register.errors.invalid")
      return render :register, status: :unprocessable_content
    end

    @beta_tester = BetaTester.new(@form.to_beta_tester_attributes)
    @beta_tester.beta_consent = true
    @beta_tester.platform = @form.platform.to_s.downcase

    ActiveRecord::Base.transaction do
      @beta_tester.save!

      result = Consents::Recorder.call(
        beta_tester: @beta_tester,
        health_data: true,
        terms: @form.terms_accepted?,
        age_18: @form.age_confirmed?,
        survey_contact: session[:survey_opt_in] == true,
        language: locale_param || I18n.locale.to_s,
        ip: request.remote_ip,
        user_agent: request.user_agent
      )
      result.records.each(&:save!)
    end

    # iOS and Android testers are invited into the store testing tracks
    # automatically (Apple / Google email them); web needs no store invite.
    InviteBetaTesterJob.perform_later(@beta_tester.id) if %w[ios android].include?(@beta_tester.platform)

    session.delete(:health_consent)
    session.delete(:health_consent_at)
    session.delete(:health_consent_version)
    session.delete(:survey_opt_in)
    session.delete(:beta_step)

    redirect_to beta_confirmed_path(locale: locale_param, platform: @beta_tester.platform)
  rescue ActiveRecord::RecordInvalid
    @form = BetaOnboarding::RegistrationForm.new(registration_params)
    flash.now[:alert] = t("beta_onboarding.register.errors.invalid")
    render :register, status: :unprocessable_content
  end

  def confirmed
    @platform = params[:platform].presence || "Web"
    case @platform.to_s.downcase
    when "ios" then @download_link = BetaTester.testflight_public_link
    when "android"
      @group_link = ENV["GOOGLE_PLAY_GROUP_URL"].presence
      @download_link = ENV["GOOGLE_PLAY_OPEN_TESTING_URL"].presence
    end
  end

  private

  def registration_params
    params.expect(beta_tester: [*BetaOnboarding::RegistrationForm.param_keys])
  end

  # German is the funnel default. An explicit ?locale= wins and is remembered
  # for the rest of the funnel so the language toggle does not reset on POST.
  # Scoped with `with_locale` so the choice cannot leak into the next request
  # handled by the same thread.
  def with_beta_locale(&action)
    session[:beta_locale] = locale_param if locale_param
    I18n.with_locale(session[:beta_locale] || :de, &action)
  end

  def locale_param
    @locale_param ||= begin
      l = params[:locale].to_s.downcase
      Legal::Content::LANGUAGES.include?(l) ? l : nil
    end
  end
end
