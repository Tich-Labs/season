class HomeController < ApplicationController
  before_action :authenticate_user!, except: [ :preview_calendar, :preview_settings ]
  before_action :check_onboarding!, except: [ :settings, :preview_calendar, :preview_settings ]

  def index
    @today = Date.today
    @calendar_month = params[:month]&.to_i || @today.month
    @calendar_year = params[:year]&.to_i || @today.year

    @start_date = Date.new(@calendar_year, @calendar_month, 1)
    @end_date = @start_date.end_of_month
    @days_in_month = @end_date.day
    @first_day_of_week = @start_date.wday

    calculate_cycle_info
  end

  def settings
  end

  def preview_calendar
    @today = Date.today
    @calendar_month = @today.month
    @calendar_year = @today.year
    @start_date = Date.new(@calendar_year, @calendar_month, 1)
    @end_date = @start_date.end_of_month
    @days_in_month = @end_date.day
    @first_day_of_week = @start_date.wday
    @cycle_day = 14
    @period_days = [ 1, 2, 3, 4, 5 ]
    render :index
  end

  def preview_settings
    @user = User.new(email: "preview@example.com", birthday: Date.new(1995, 5, 15), cycle_length: 28, period_length: 5)
    render :settings
  end

  private

  def check_onboarding!
    return if current_user&.birthday.present? && current_user&.cycle_length.present?
    redirect_to onboarding_path(step: 1)
  end

  def calculate_cycle_info
    return unless current_user&.birthday && current_user.cycle_length

    cycle_length = current_user.cycle_length || 28
    period_length = current_user.period_length || 5

    today = Date.today
    cycle_day = ((today - current_user.birthday).to_i % cycle_length) + 1

    @cycle_day = cycle_day
    @period_start = cycle_day <= period_length
    @days_until_period = cycle_length - cycle_day + 1

    @period_days = []
    period_start_day = (cycle_day <= period_length) ? cycle_day : nil
    if period_start_day
      period_start_day.upto(period_length) { |d| @period_days << d }
    end
  end
end
