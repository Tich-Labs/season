class CalendarController < ApplicationController
  include Authentication

  before_action :require_onboarding_completed

  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    @year = @date.year
    @month = @date.month

    if current_user.last_period_start
      calculator = CycleCalculatorService.new(current_user)
      @month_data = calculator.month_data(@year, @month).index_by { |d| d[:date] }
    else
      @month_data = {}
    end

    @events = current_user.calendar_events
      .where(date: Date.new(@year, @month, 1)..Date.new(@year, @month, -1))
      .order(:date, :start_time)

    @tracked_days = current_user.symptom_logs
      .where(date: Date.new(@year, @month, 1)..Date.new(@year, @month, -1))
      .pluck(:date).to_set

    @prev_month = @date - 1.month
    @next_month = @date + 1.month

    @current_phase = current_user.current_phase
    @current_season = current_user.current_phase ?
      CycleCalculatorService::SEASON_NAMES[current_user.current_phase] : nil
    @streak = current_user.streak&.current_streak || 0
  end
end
