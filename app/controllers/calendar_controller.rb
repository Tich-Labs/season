class CalendarController < ApplicationController
  VALID_MODES = %w[all events tracking cycle].freeze
  include CalendarHelper

  private

  def load_calendar_preferences
    @show_appointments = current_user.show_appointments?
    @show_cycledays = current_user.show_cycledays?
    @show_moonphases = current_user.show_moonphases?
    @show_holidays = current_user.show_holidays?
    @show_week_numbers = current_user.show_week_numbers?
  end

  public

  def appointments
    load_calendar_preferences
    @date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
    @year = @date.year
    @month = @date.month

    month_range = Date.new(@year, @month, 1)..Date.new(@year, @month, -1)

    @events_by_date = if @show_appointments
      current_user.calendar_events
        .where(date: month_range)
        .order(:date, :start_time)
        .group_by(&:date)
    else
      {}
    end

    if current_user.last_period_start
      calculator = CycleCalculatorService.new(current_user)
      @cycle_by_date = calculator.month_data(@year, @month).index_by { |d| d[:date] }
    else
      @cycle_by_date = {}
    end

    @holidays_by_date = @show_holidays ? holidays_for_month(@year, @month) : {}
    @prev_month = @date - 1.month
    @next_month = @date + 1.month
  end

  def weekly
    load_calendar_preferences
    @date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
    @week_start = @date.beginning_of_week
    @week_end = @date.end_of_week

    # Get week dates
    @week_dates = (@week_start..@week_end).to_a

    # Calculate previous/next week
    @prev_week = @week_start - 1.week
    @next_week = @week_start + 1.week

    # Get events for this week
    @events_by_date = if @show_appointments
      week_range = @week_start..@week_end
      current_user.calendar_events
        .where(date: week_range)
        .order(:date, :start_time)
        .group_by(&:date)
    else
      {}
    end

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
    @holidays_by_date = @show_holidays ? holidays_for_month(@date.year, @date.month) : {}
    @week_dates_with_numbers = @week_dates.index_with { |d| iso_week_number(d) }
  end

  def index
    load_calendar_preferences
    @date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
    @year = @date.year
    @month = @date.month
    @mode = VALID_MODES.include?(params[:mode]) ? params[:mode] : "all"

    month_range = Date.new(@year, @month, 1)..Date.new(@year, @month, -1)

    # Cycle phase data — keyed by date, O(1) lookup
    if current_user.last_period_start && (@show_cycledays || @mode == "cycle")
      calculator = CycleCalculatorService.new(current_user)
      @cycle_by_date = calculator.month_data(@year, @month).index_by { |d| d[:date] }
      @current_phase = calculator.current_phase
    else
      @cycle_by_date = {}
      @current_phase = nil
    end

    # Events — keyed by date as Set for O(1) presence check, list for detail
    @events_by_date = if @show_appointments
      current_user.calendar_events
        .where(date: month_range)
        .order(:date, :start_time)
        .group_by(&:date)
    else
      {}
    end

    # Tracked days — Set for O(1) lookup
    @tracked_days_set = current_user.symptom_logs
      .where(date: month_range)
      .pluck(:date)
      .to_set

    @prev_month = @date - 1.month
    @next_month = @date + 1.month

    @current_season = CycleCalculatorService::SEASON_NAMES[@current_phase]
    @streak = current_user.streak&.current_streak || 0
    @holidays_by_date = @show_holidays ? holidays_for_month(@year, @month) : {}
  end
end
