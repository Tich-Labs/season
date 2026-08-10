class CalendarController < ApplicationController
  VALID_MODES = %w[all events tracking cycle].freeze
  include CalendarHelper

  private

  def load_calendar_preferences
    @show_appointments = current_user.show_appointments?
    @show_cycledays = true
    @show_moonphases = current_user.show_moonphases?
    @show_holidays = current_user.show_holidays?
    @show_week_numbers = current_user.show_week_numbers?
    @show_cycle_day_on_band = current_user.show_cycle_day_on_band?
    @show_tracked_days = current_user.show_tracked_days?
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
      @current_phase = calculator.current_phase
    else
      @cycle_by_date = {}
      @current_phase = nil
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

    month_start = Date.new(@year, @month, 1)
    month_end = Date.new(@year, @month, -1)
    first_weekday = (month_start.wday == 0) ? 6 : month_start.wday - 1
    trailing = (7 - ((first_weekday + month_end.day) % 7)) % 7
    prev_tail_dates = (month_start - first_weekday..month_start - 1).to_a
    next_head_dates = (month_end + 1..month_end + trailing).to_a
    full_dates = prev_tail_dates + (month_start..month_end).to_a + next_head_dates

    # A month can need 6 calendar rows (e.g. a 31-day month starting on a
    # Saturday) but the screen only has room for 5. Cap it: while we're still
    # in the first row, show the first 5 weeks; once the first row's date
    # range has passed, drop it and show the last 5 weeks instead. Either way
    # we only ever render 5 rows.
    weeks = full_dates.each_slice(7).to_a
    @calendar_dates = if weeks.size > 5
      reference_date = (@date.month == @month) ? @date : Time.zone.today
      in_first_week = weeks.first.include?(reference_date)
      (in_first_week ? weeks.first(5) : weeks.last(5)).flatten
    else
      full_dates
    end

    full_start = prev_tail_dates.first || month_start
    full_end = next_head_dates.last || month_end

    # Cycle phase data — keyed by date, covers adjacent months
    if current_user.last_period_start && (@show_cycledays || @mode == "cycle")
      calculator = CycleCalculatorService.new(current_user)
      @cycle_by_date = (
        calculator.month_data(full_start.year, full_start.month) +
        calculator.month_data(@year, @month) +
        calculator.month_data(full_end.year, full_end.month)
      ).index_by { |d| d[:date] }
      @current_phase = calculator.current_phase
    else
      @cycle_by_date = {}
      @current_phase = nil
    end

    # Events — keyed by date, covers adjacent months
    @events_by_date = if @show_appointments
      current_user.calendar_events
        .where(date: full_start..full_end)
        .order(:date, :start_time)
        .group_by(&:date)
    else
      {}
    end

    # Tracked days — Set for O(1) lookup, covers adjacent months.
    # Hidden entirely when the user disables "Tracked Days" in Settings > Calendar.
    @tracked_days_set = if @show_tracked_days
      current_user.symptom_logs
        .where(date: full_start..full_end)
        .pluck(:date)
        .to_set
        .merge(current_user.superpower_logs.where(date: full_start..full_end).pluck(:date))
    else
      Set.new
    end

    @prev_month = @date - 1.month
    @next_month = @date + 1.month

    @current_season = CycleCalculatorService::SEASON_NAMES[@current_phase]
    @streak = current_user.streak&.current_streak || 0
    @holidays_by_date = @show_holidays ? holidays_for_month(@year, @month) : {}
  end
end
