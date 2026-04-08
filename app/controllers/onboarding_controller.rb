class OnboardingController < ApplicationController
  layout "launch", except: [:invite]
  allow_unauthenticated_access only: [:invite]

  def invite
    @token = params[:token]
    @hide_nav = true
    render layout: "application"
  end

  def show
    @step = params[:id].to_i
    @hide_nav = true
    render layout: "application"
  end

  def update
    @step = params[:id].to_i
    @hide_nav = true

    case @step
    when 1
      name = params.dig(:user, :name)
      if name.blank?
        @error = "Please enter your name"
        render :show, status: :unprocessable_entity
        return
      end
      current_user.update!(name: name)

    when 2
      cycle_length = params[:cycle_length].to_i
      period_length = params[:period_length].to_i
      if cycle_length < 21 || cycle_length > 35 || period_length < 1 || period_length > 10
        @error = "Please select valid values"
        render :show, status: :unprocessable_entity
        return
      end
      current_user.update!(
        cycle_length: cycle_length,
        period_length: period_length
      )

    when 3
      contraception = params[:contraception]
      if contraception.blank?
        @error = "Please select an option"
        render :show, status: :unprocessable_entity
        return
      end
      current_user.update!(contraception_type: contraception)

    when 4
      last_period_date = params[:last_period_date]
      if last_period_date.blank?
        @error = "Please select a date"
        render :show, status: :unprocessable_entity
        return
      end
      current_user.update!(last_period_start: last_period_date)

    when 5
      locale = params[:locale]
      if locale.blank?
        @error = "Please select a language"
        render :show, status: :unprocessable_entity
        return
      end
      current_user.update!(
        language: locale,
        onboarding_completed: true
      )
    end

    if @step < 5
      redirect_to onboarding_path(@step + 1)
    else
      redirect_to user_root_path
    end
  rescue ActiveRecord::RecordInvalid => e
    @error = e.message
    render :show, status: :unprocessable_entity
  end

  def finish
    redirect_to user_root_path if authenticated?
  end

  private

  def require_completed_onboarding
    redirect_to user_root_path if !authenticated? || current_user.onboarding_completed?
  end

  def require_user!
    return if current_user
    redirect_to new_session_path, alert: "Please sign in first"
  end
end
