class OnboardingController < ApplicationController
  layout "launch", except: [:invite]
  allow_unauthenticated_access only: [:show, :invite, :finish]
  skip_onboarding_requirement
  allow_pin_bypass

  TOTAL_STEPS = 10

  def invite
    @token = params[:token]
    @hide_nav = true
  end

  def show
    @step = params[:id].to_i
    @hide_nav = true
    @no_regular_cycle = params[:no_regular].present?

    return unless authenticated?

    if current_user.profile_complete?
      redirect_to user_root_path and return
    end

    resume_step = current_user.next_onboarding_step
    previously_reached = session[:onboarding_reached_step].to_i

    # Only force the user forward to their resume point if this session
    # hasn't already reached it — e.g. a fresh sign-in after dropping off
    # mid-onboarding. If they've already reached the resume point once in
    # this session, landing on an earlier step (via the back button or
    # browser back) is an intentional revisit to review or change an
    # answer, not a stale resume — so let it through.
    if resume_step && resume_step > @step && previously_reached < resume_step
      redirect_to onboarding_path(resume_step) and return
    end

    session[:onboarding_reached_step] = [previously_reached, @step].max
  end

  def update
    @step = params[:id].to_i
    @hide_nav = true

    case @step
    when 1
      # Name
      name = begin
        params.expect(user: [:name])[:name]
      rescue ActionController::ParameterMissing
        params.dig(:user, :name)
      end
      if name.blank?
        @error = t(".name_required", default: "Please enter your name")
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
        raise ArgumentError if birthday > Time.zone.today || year < 1946
        current_user.update!(birthday: birthday)
      rescue ArgumentError, TypeError
        @error = t(".invalid_birthday", default: "Please enter a valid date of birth")
        render :show, status: :unprocessable_content
        return
      end
      redirect_to onboarding_path(3) and return

    when 3
      # First & last day of last period (single date-range picker)
      if params[:skip_last_period].present?
        redirect_to onboarding_path(4) and return
      end
      start_date = params[:last_period_start]
      end_date = params[:last_period_end]
      if start_date.blank?
        @error = "Please select a date or tap Unsure"
        render :show, status: :unprocessable_content
        return
      end
      begin
        parsed_start = Date.iso8601(start_date)
        parsed_end = end_date.present? ? Date.iso8601(end_date) : nil
        ApplicationRecord.transaction do
          updates = {last_period_start: parsed_start}
          updates[:last_period_end] = parsed_end if parsed_end
          current_user.update!(updates)
          current_user.period_starts.find_or_create_by!(started_on: parsed_start)
        end
      rescue ArgumentError, TypeError
        @error = "Invalid date — please select again"
        render :show, status: :unprocessable_content and return
      end
      redirect_to onboarding_path(4) and return

    when 4
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
        redirect_to onboarding_path(5) and return
      else
        redirect_to onboarding_path(5, no_regular: true) and return
      end

    when 5
      # Cycle length
      if params[:skip_cycle_length].present?
        # TODO: Auto-calculate from user's tracking data over time
        current_user.update!(cycle_length: 28)
        redirect_to onboarding_path(6) and return
      end
      cycle_length = params[:cycle_length].to_i
      if cycle_length < 20 || cycle_length > 45
        @error = "Please select a valid cycle length"
        render :show, status: :unprocessable_content
        return
      end
      current_user.update!(cycle_length: cycle_length)
      redirect_to onboarding_path(6) and return

    when 6
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
        redirect_to onboarding_path(8) and return
      else
        redirect_to onboarding_path(7) and return
      end

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
      # Birth control method
      method = params[:birth_control_method]
      if method.blank?
        @error = "Please select a method"
        render :show, status: :unprocessable_content
        return
      end
      current_user.update!(contraception_type: method)
      redirect_to onboarding_path(9) and return

    when 9
      # Cycle stage reminder
      if params[:skip_reminder].present?
        current_user.update!(cycle_stage_reminder: false)
      else
        current_user.update!(cycle_stage_reminder: true)
      end
      redirect_to onboarding_path(10) and return

    when 10
      # Food preferences
      food_pref = params[:food_preference]
      if food_pref.blank?
        @error = "Please select an option"
        render :show, status: :unprocessable_content
        return
      end
      current_user.update!(food_preference: food_pref, onboarding_completed: true)
      redirect_to onboarding_finish_path and return
    end
  rescue ActiveRecord::RecordInvalid => e
    @error = e.message
    render :show, status: :unprocessable_content
  end

  def finish
    # Also set a Refresh header as a fallback to ensure redirect works
    response.headers["Refresh"] = "1.5;url=#{calendar_path}"
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
