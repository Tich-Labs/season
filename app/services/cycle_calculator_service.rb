class CycleCalculatorService
  MIN_CYCLE_LENGTH = 20
  MAX_CYCLE_LENGTH = 60
  ROLLING_AVERAGE_WINDOW = 6

  # Single source of truth for phase presentation — used by all views and controllers.
  PHASE_META = {
    "menstrual" => {colour: "#933a35", text_colour: "#FFFFFF", season: "Winter", days: "Day 1–5"},
    "follicular" => {colour: "#899884", text_colour: "#FFFFFF", season: "Spring", days: "Day 6–13"},
    "ovulation" => {colour: "#50715b", text_colour: "#FFFFFF", season: "Summer", days: "Day 14–21"},
    "luteal" => {colour: "#D18D84", text_colour: "#FFFFFF", season: "Autumn", days: "Day 22–28"}
  }.freeze

  PHASE_COLOURS = PHASE_META.transform_values { |m| m[:colour] }.freeze
  SEASON_NAMES = PHASE_META.transform_values { |m| m[:season] }.freeze

  # Hormonal contraceptives that suppress ovulation — only menstrual vs follicular distinction applies.
  HORMONAL_BC_TYPES = %w[pill hormonering plaster].freeze

  def initialize(user)
    @user = user
    @period_length = user.period_length || 5
    @hormonal_bc = user.uses_hormonal_birth_control &&
      HORMONAL_BC_TYPES.include?(user.contraception_type.to_s)

    # Ordered list of actual logged period start dates.
    # Falls back to the legacy last_period_start column for users without
    # period_starts rows (e.g. pre-migration or test fixtures).
    @period_starts = user.period_starts.ordered.pluck(:started_on)
    if @period_starts.empty? && user.last_period_start
      @period_starts = [user.last_period_start.to_date]
    end

    # Actual gaps between consecutive logged starts.
    @actual_gaps = @period_starts.each_cons(2).map { |a, b| (b - a).to_i }

    # Rolling average of the most recent actual gaps for forward prediction.
    @predicted_gap = compute_predicted_gap
  end

  def current_phase
    return nil if @period_starts.empty?
    phase_for_date(Time.zone.today)
  end

  def current_season
    SEASON_NAMES[current_phase]
  end

  def current_cycle_day
    return nil if @period_starts.empty?
    latest = @period_starts.last
    ((Time.zone.today - latest).to_i % @predicted_gap) + 1
  end

  def next_period_start
    return nil if @period_starts.empty?
    latest = @period_starts.last
    today = Time.zone.today
    if today <= latest
      latest + @predicted_gap
    else
      cycles_since = (today - latest).to_i / @predicted_gap
      latest + ((cycles_since + 1) * @predicted_gap)
    end
  end

  def phase_for_date(date)
    prev_start, gap = cycle_bounds_for(date)
    return nil unless prev_start && gap

    cycle_day = ((date.to_date - prev_start).to_i % gap) + 1

    if cycle_day <= @period_length
      "menstrual"
    elsif cycle_day <= gap - 14
      "follicular"
    elsif cycle_day <= gap - 14 + 7
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
    return [] if @period_starts.empty?
    start_date = Date.new(year, month, 1)
    end_date = Date.new(year, month, -1)
    (start_date..end_date).map do |date|
      phase = effective_phase_for_date(date)
      prev_start, gap, predicted = cycle_context_for(date)
      {
        date: date,
        phase: phase,
        season: SEASON_NAMES[phase],
        colour: PHASE_COLOURS[phase],
        cycle_day: prev_start ? ((date - prev_start).to_i % gap) + 1 : nil,
        predicted: predicted
      }
    end
  end

  def week_data(week_start)
    return [] if @period_starts.empty?
    week_end = week_start + 6
    (week_start..week_end).map do |date|
      phase = effective_phase_for_date(date)
      prev_start, gap, predicted = cycle_context_for(date)
      {
        date: date,
        phase: phase,
        season: SEASON_NAMES[phase],
        colour: PHASE_COLOURS[phase],
        cycle_day: prev_start ? ((date - prev_start).to_i % gap) + 1 : nil,
        predicted: predicted
      }
    end
  end

  # Returns recent cycle days for the Self Analysis day strip.
  # Produces `count` entries centred on today (past_days before + today + future_days after).
  def strip_data(past_days: 6, future_days: 6, center: Time.zone.today)
    return [] if @period_starts.empty?
    ((center - past_days)..(center + future_days)).map do |date|
      phase = effective_phase_for_date(date)
      prev_start, gap = cycle_bounds_for(date)
      cycle_day = prev_start ? ((date - prev_start).to_i % gap) + 1 : nil
      {
        date: date,
        cycle_day: cycle_day,
        phase: phase,
        colour: PHASE_COLOURS[phase],
        current: date == center
      }
    end
  end

  # Arc data for the SVG cycle wheel: each phase as start/end angle in degrees.
  # Angles start from the top (–90°) and go clockwise.
  # For hormonal BC users, collapses to 2 slices: menstrual + follicular.
  # Guards against negative day counts by clamping to a minimum of 1.
  def wheel_arcs
    effective_length = [@predicted_gap, MIN_CYCLE_LENGTH].max
    period_days = [@period_length, 1].max

    slices = if @hormonal_bc
      follicular_days = [effective_length - period_days, 1].max
      [
        {phase: "menstrual", days: period_days},
        {phase: "follicular", days: follicular_days}
      ]
    else
      follicular_days = [effective_length - 14 - period_days, 1].max
      ovulation_days = 7
      luteal_days = [effective_length - period_days - follicular_days - ovulation_days, 1].max
      [
        {phase: "menstrual", days: period_days},
        {phase: "follicular", days: follicular_days},
        {phase: "ovulation", days: ovulation_days},
        {phase: "luteal", days: luteal_days}
      ]
    end

    offset = -90.0
    total_days = slices.sum { |s| s[:days] }
    effective_total = [total_days, 1].max

    slices.map do |s|
      sweep = (s[:days].to_f / effective_total) * 360
      arc = {phase: s[:phase], colour: PHASE_COLOURS[s[:phase]],
             start_angle: offset, end_angle: offset + sweep, days: s[:days]}
      offset += sweep
      arc
    end
  end

  private

  def compute_predicted_gap
    return @user.cycle_length || 28 if @actual_gaps.empty?

    recent = @actual_gaps.last([@actual_gaps.length, ROLLING_AVERAGE_WINDOW].min)
    avg = (recent.sum.to_f / recent.length).round
    avg.clamp(MIN_CYCLE_LENGTH, MAX_CYCLE_LENGTH)
  end

  # Returns [prev_start, gap] — the period start that brackets `date` and the
  # effective cycle length (actual or predicted) for phase calculations.
  def cycle_bounds_for(date)
    prev_start, gap = cycle_context_for(date)
    [prev_start, gap]
  end

  # Returns [prev_start, gap, predicted] triple.
  # - predicted is true when the gap is predicted (forward projection).
  # - nil prev_start means no cycle data for this date.
  def cycle_context_for(date)
    date = date.to_date
    prev_idx = @period_starts.rindex { |s| s <= date }
    return [nil, nil, false] unless prev_idx

    prev_start = @period_starts[prev_idx]

    if prev_idx + 1 < @period_starts.length
      next_start = @period_starts[prev_idx + 1]
      gap = (next_start - prev_start).to_i
      [prev_start, gap, false]
    else
      [prev_start, @predicted_gap, true]
    end
  end
end
