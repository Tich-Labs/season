class DailyViewController < ApplicationController
  before_action :require_onboarding_completed

  def show
    @date = if params[:date] == "today"
      Time.zone.today
    else
      (params[:date] ? Date.parse(params[:date]) : Time.zone.today)
    end

    if current_user.last_period_start
      calculator = CycleCalculatorService.new(current_user)
      @phase = calculator.phase_for_date(@date)
      @season = CycleCalculatorService::SEASON_NAMES[@phase]
      @cycle_day = calculator.current_cycle_day
      @content = CyclePhaseContent.for(@phase, current_user.language || "en") if @phase
    else
      @phase = nil
      @season = nil
      @cycle_day = nil
      @content = nil
    end

    @events = current_user.calendar_events.where(date: @date).order(:start_time)
    @symptom_log = current_user.symptom_logs.find_by(date: @date)

    @week_dates = (0..6).map { |i| @date.beginning_of_week(:monday) + i.days }
    @all_day_events = @events.select { |e| e.start_time.nil? }
    @timed_events = @events.select { |e| e.start_time.present? }
    @phase_colour = @phase ? CycleCalculatorService::PHASE_COLOURS[@phase] : "#933a35"
  end
end
