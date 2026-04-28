class CycleCalculatorService
  # Single source of truth for phase presentation — used by all views and controllers.
  PHASE_META = {
    "menstrual" => {colour: "#933a35", text_colour: "#FFFFFF", season: "Winter", days: "Day 1–5"},
    "follicular" => {colour: "#899884", text_colour: "#FFFFFF", season: "Spring", days: "Day 6–13"},
    "ovulation" => {colour: "#50705b", text_colour: "#FFFFFF", season: "Summer", days: "Day 14–21"},
    "luteal" => {colour: "#D18D83", text_colour: "#FFFFFF", season: "Autumn", days: "Day 22–28"}
  }.freeze

  PHASE_COLOURS = PHASE_META.transform_values { |m| m[:colour] }.freeze
  SEASON_NAMES = PHASE_META.transform_values { |m| m[:season] }.freeze

  # Hormonal contraceptives that suppress ovulation — only menstrual vs follicular distinction applies.
  HORMONAL_BC_TYPES = %w[pill hormonering plaster].freeze

  def initialize(user)
    @user = user
    @cycle_length = user.cycle_length || 28
    @period_length = user.period_length || 5
    @last_period_start = user.last_period_start
    @hormonal_bc = user.uses_hormonal_birth_control &&
      HORMONAL_BC_TYPES.include?(user.contraception_type.to_s)
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

  def next_period_start
    return nil unless @last_period_start
    last = @last_period_start.to_date
    today = Time.zone.today
    cycles = (today - last).to_i / @cycle_length
    last + ((cycles + 1) * @cycle_length)
  end

  def phase_for_date(date)
    return nil unless @last_period_start
    cycle_day = ((date - @last_period_start.to_date).to_i % @cycle_length) + 1
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

  # Like phase_for_date but collapses ovulation/luteal → follicular for users
  # on hormonal BC (pill/ring/plaster) since those phases are suppressed.
  def effective_phase_for_date(date)
    phase = phase_for_date(date)
    return phase unless @hormonal_bc
    (phase == "menstrual") ? "menstrual" : "follicular"
  end

  def colour_for_date(date)
    PHASE_COLOURS[effective_phase_for_date(date)]
  end

  def month_data(year, month)
    return [] unless @last_period_start
    start_date = Date.new(year, month, 1)
    end_date = Date.new(year, month, -1)
    (start_date..end_date).map do |date|
      phase = effective_phase_for_date(date)
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

  def week_data(week_start)
    return [] unless @last_period_start
    week_end = week_start + 6
    (week_start..week_end).map do |date|
      phase = effective_phase_for_date(date)
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

  # Returns recent cycle days for the Self Analysis day strip.
  # Produces `count` entries centred on today (past_days before + today + future_days after).
  def strip_data(past_days: 6, future_days: 6)
    return [] unless @last_period_start
    today = Time.zone.today
    ((today - past_days)..(today + future_days)).map do |date|
      phase = effective_phase_for_date(date)
      cycle_day = ((date - @last_period_start.to_date).to_i % @cycle_length) + 1
      {
        date: date,
        cycle_day: cycle_day,
        phase: phase,
        colour: PHASE_COLOURS[phase],
        current: date == today
      }
    end
  end

  # Arc data for the SVG cycle wheel: each phase as start/end angle in degrees.
  # Angles start from the top (–90°) and go clockwise.
  # For hormonal BC users, collapses to 2 slices: menstrual + follicular.
  def wheel_arcs
    period_days = @period_length
    slices = if @hormonal_bc
      follicular_days = @cycle_length - period_days
      [
        {phase: "menstrual", days: period_days},
        {phase: "follicular", days: follicular_days}
      ]
    else
      follicular_days = @cycle_length - 14 - period_days
      ovulation_days = 7
      luteal_days = @cycle_length - period_days - follicular_days - ovulation_days
      [
        {phase: "menstrual", days: period_days},
        {phase: "follicular", days: follicular_days},
        {phase: "ovulation", days: ovulation_days},
        {phase: "luteal", days: luteal_days}
      ]
    end

    offset = -90.0
    slices.map do |s|
      sweep = (s[:days].to_f / @cycle_length) * 360
      arc = {phase: s[:phase], colour: PHASE_COLOURS[s[:phase]],
             start_angle: offset, end_angle: offset + sweep, days: s[:days]}
      offset += sweep
      arc
    end
  end
end
