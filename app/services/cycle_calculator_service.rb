class CycleCalculatorService
  PHASE_COLOURS = {
    "menstrual" => "#933a35",
    "follicular" => "#C8956A",
    "ovulation" => "#2E6B3E",
    "luteal" => "#7D5A1E"
  }.freeze

  SEASON_NAMES = {
    "menstrual" => "Winter",
    "follicular" => "Spring",
    "ovulation" => "Summer",
    "luteal" => "Autumn"
  }.freeze

  def initialize(user)
    @user = user
    @cycle_length = user.cycle_length || 28
    @period_length = user.period_length || 5
    @last_period_start = user.last_period_start
  end

  def current_phase
    return nil unless @last_period_start
    phase_for_date(Time.zone.today)
  end

  def current_season
    SEASON_NAMES[current_phase]
  end

  def current_cycle_day
    return nil unless @last_period_start
    ((Time.zone.today - @last_period_start.to_date).to_i %
      @cycle_length) + 1
  end

  def phase_for_date(date)
    return nil unless @last_period_start
    cycle_day = ((date - @last_period_start.to_date).to_i %
                  @cycle_length) + 1
    if cycle_day <= @period_length
      "menstrual"
    elsif cycle_day <= @cycle_length - 14
      "follicular"
    elsif cycle_day <= @cycle_length - 14 + 7
      "ovulation"
    else
      "luteal"
    end
  end

  def colour_for_date(date)
    PHASE_COLOURS[phase_for_date(date)]
  end

  def month_data(year, month)
    return [] unless @last_period_start
    start_date = Date.new(year, month, 1)
    end_date = Date.new(year, month, -1)
    (start_date..end_date).map do |date|
      phase = phase_for_date(date)
      {
        date: date,
        phase: phase,
        season: SEASON_NAMES[phase],
        colour: PHASE_COLOURS[phase],
        cycle_day: ((date - @last_period_start.to_date)
          .to_i % @cycle_length) + 1
      }
    end
  end
end
