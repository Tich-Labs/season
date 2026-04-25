class CalendarController < ApplicationController

  VALID_MODES = %w[all events tracking cycle].freeze

  def appointments
    @date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
    @year = @date.year
    @month = @date.month

    month_range = Date.new(@year, @month, 1)..Date.new(@year, @month, -1)

    @events_by_date = current_user.calendar_events
      .where(date: month_range)
      .order(:date, :start_time)
      .group_by(&:date)

    if current_user.last_period_start
      calculator = CycleCalculatorService.new(current_user)
      @cycle_by_date = calculator.month_data(@year, @month).index_by { |d| d[:date] }
    else
      @cycle_by_date = {}
    end

    @prev_month = @date - 1.month
    @next_month = @date + 1.month
  end

  def weekly
    @date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
    @week_start = @date.beginning_of_week
    @week_end = @date.end_of_week

    # Get week dates
    @week_dates = (@week_start..@week_end).to_a

    # Calculate previous/next week
    @prev_week = @week_start - 1.week
    @next_week = @week_start + 1.week

    # Get events for this week
    week_range = @week_start..@week_end
    @events_by_date = current_user.calendar_events
      .where(date: week_range)
      .order(:date, :start_time)
      .group_by(&:date)

    # Cycle data for the week
    if current_user.last_period_start
      calculator = CycleCalculatorService.new(current_user)
      @cycle_by_date = calculator.week_data(@week_start).index_by { |d| d[:date] }
      @current_phase = calculator.current_phase
    else
      @cycle_by_date = {}
      @current_phase = nil
    end

    @current_season = CycleCalculatorService::SEASON_NAMES[@current_phase]
  end

  def index
    @date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
    @year = @date.year
    @month = @date.month
    @mode = VALID_MODES.include?(params[:mode]) ? params[:mode] : "all"

    month_range = Date.new(@year, @month, 1)..Date.new(@year, @month, -1)

    # Cycle phase data — keyed by date, O(1) lookup
    if current_user.last_period_start
      calculator = CycleCalculatorService.new(current_user)
      @cycle_by_date = calculator.month_data(@year, @month).index_by { |d| d[:date] }
      @current_phase = calculator.current_phase
    else
      @cycle_by_date = {}
      @current_phase = nil
    end

    # Events — keyed by date as Set for O(1) presence check, list for detail
    @events_by_date = current_user.calendar_events
      .where(date: month_range)
      .order(:date, :start_time)
      .group_by(&:date)

    # Tracked days — Set for O(1) lookup
    @tracked_days_set = current_user.symptom_logs
      .where(date: month_range)
      .pluck(:date)
      .to_set

    @prev_month = @date - 1.month
    @next_month = @date + 1.month

    @current_season = CycleCalculatorService::SEASON_NAMES[@current_phase]
    @streak = current_user.streak&.current_streak || 0
  end
end
