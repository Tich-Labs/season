class OnboardingController < ApplicationController
  layout "launch", except: [:invite]
  allow_unauthenticated_access only: [:show, :invite]
  skip_onboarding_requirement

  TOTAL_STEPS = 11

  def invite
    @token = params[:token]
    @hide_nav = true
    render layout: "application"
  end

  def show
    @step = params[:id].to_i
    @hide_nav = true
    @no_regular_cycle = params[:no_regular].present?

    if authenticated? && current_user.profile_complete?
      redirect_to user_root_path and return
    end

    render layout: "application"
  end

  def update
    @step = params[:id].to_i
    @hide_nav = true

    case @step
    when 1
      # Name
      name = params.dig(:user, :name)
      if name.blank?
        @error = "Please enter your name"
        render :show, status: :unprocessable_content
        return
      end
      current_user.update!(name: name)
      redirect_to onboarding_path(2) and return

    when 2
      # Birthday
      day = params[:birthday_day].to_i
      month = params[:birthday_month].to_i
      year = params[:birthday_year].to_i
      begin
        birthday = Date.new(year, month, day)
        raise ArgumentError if birthday > Time.zone.today || year < 1900
        current_user.update!(birthday: birthday)
      rescue ArgumentError, TypeError
        @error = "Please enter a valid date of birth"
        render :show, status: :unprocessable_content
        return
      end
      redirect_to onboarding_path(3) and return

    when 3
      # Regular cycle?
      regular = params[:has_regular_cycle]
      if regular.blank?
        @error = "Please select an option"
        render :show, status: :unprocessable_content
        return
      end
      has_regular = regular == "true"
      current_user.update!(has_regular_cycle: has_regular)
      if has_regular
        redirect_to onboarding_path(4) and return
      else
        redirect_to onboarding_path(4, no_regular: true) and return
      end

    when 4
      # Cycle length
      if params[:skip_cycle_length].present?
        current_user.update!(cycle_length: 28) # default
        redirect_to onboarding_path(5) and return
      end
      cycle_length = params[:cycle_length].to_i
      if cycle_length < 20 || cycle_length > 45
        @error = "Please select a valid cycle length"
        render :show, status: :unprocessable_content
        return
      end
      current_user.update!(cycle_length: cycle_length)
      redirect_to onboarding_path(5) and return

    when 5
      # Hormonal birth control?
      hormonal = params[:uses_hormonal_birth_control]
      if hormonal.blank?
        @error = "Please select an option"
        render :show, status: :unprocessable_content
        return
      end
      uses_hormonal = hormonal == "true"
      current_user.update!(uses_hormonal_birth_control: uses_hormonal)
      if uses_hormonal
        redirect_to onboarding_path(6) and return
      else
        redirect_to onboarding_path(8) and return
      end

    when 6
      # Birth control method
      method = params[:birth_control_method]
      if method.blank?
        @error = "Please select a method"
        render :show, status: :unprocessable_content
        return
      end
      current_user.update!(contraception_type: method)
      redirect_to onboarding_path(7) and return

    when 7
      # Birth control reminder
      reminder = params[:birth_control_reminder]
      if reminder.blank?
        @error = "Please select an option"
        render :show, status: :unprocessable_content
        return
      end
      current_user.update!(birth_control_reminder: reminder == "true")
      redirect_to onboarding_path(8) and return

    when 8
      # Contraception (taking any?)
      contraception = params[:contraception]
      if contraception.blank?
        @error = "Please select an option"
        render :show, status: :unprocessable_content
        return
      end
      current_user.update!(contraception_type: contraception) unless current_user.uses_hormonal_birth_control?
      redirect_to onboarding_path(9) and return

    when 9
      # Food preferences
      food_pref = params[:food_preference]
      if food_pref.blank?
        @error = "Please select an option"
        render :show, status: :unprocessable_content
        return
      end
      current_user.update!(food_preference: food_pref)
      redirect_to onboarding_path(10) and return

    when 10
      # Last period calendar
      if params[:skip_last_period].present?
        redirect_to onboarding_path(11) and return
      end
      last_period_date = params[:last_period_date]
      if last_period_date.blank?
        @error = "Please select a date or tap Unsure"
        render :show, status: :unprocessable_content
        return
      end
      parsed_date = Date.parse(last_period_date)
      current_user.update!(last_period_start: parsed_date)
      redirect_to onboarding_path(11) and return

    when 11
      # Cycle stage reminder
      if params[:skip_reminder].present?
        current_user.update!(cycle_stage_reminder: false, onboarding_completed: true)
      else
        current_user.update!(cycle_stage_reminder: true, onboarding_completed: true)
      end
      redirect_to onboarding_finish_path and return
    end
  rescue ActiveRecord::RecordInvalid => e
    @error = e.message
    render :show, status: :unprocessable_content
  end

  def finish
    # Redirect handled in view via JS
  end

  private

  def require_completed_onboarding
    redirect_to user_root_path if !authenticated? || current_user.profile_complete?
  end

  def require_user!
    return if current_user
    redirect_to new_session_path, alert: t(".sign_in_first")
  end
end
