require "test_helper"
require "ostruct"

class CycleCalculatorServiceTest < ActiveSupport::TestCase
  # Lightweight stub — duck-types all attributes the service reads
  UserStub = Struct.new(:cycle_length, :period_length, :last_period_start,
    :uses_hormonal_birth_control, :contraception_type, :period_starts)

  # Fixed reference date: 1 Jan 2026 (Thursday)
  PERIOD_START = Date.new(2026, 1, 1)

  def service_for(cycle_length: 28, period_length: 5, last_period_start: PERIOD_START,
    uses_hormonal_birth_control: false, contraception_type: "none",
    period_start_dates: nil)
    starts = period_start_dates || (last_period_start ? [last_period_start] : [])
    period_starts_mock = build_period_starts_mock(starts)

    user = UserStub.new(
      cycle_length,
      period_length,
      last_period_start,
      uses_hormonal_birth_control,
      contraception_type,
      period_starts_mock
    )
    CycleCalculatorService.new(user)
  end

  def build_period_starts_mock(dates)
    objects = dates.map { |d| OpenStruct.new(started_on: d) }
    assoc = Object.new
    assoc.define_singleton_method(:ordered) { self }
    assoc.define_singleton_method(:pluck) { |col| objects.map { |o| o.send(col) } }
    assoc
  end

  # --- phase_for_date (28-day cycle, 5-day period) ---

  test "returns menstrual on cycle day 1" do
    svc = service_for
    assert_equal "menstrual", svc.phase_for_date(PERIOD_START)
  end

  test "returns menstrual on the last day of the period" do
    svc = service_for
    assert_equal "menstrual", svc.phase_for_date(PERIOD_START + 4)
  end

  test "returns follicular the day after the period ends" do
    svc = service_for
    assert_equal "follicular", svc.phase_for_date(PERIOD_START + 5)
  end

  test "returns follicular on cycle day 14" do
    svc = service_for
    assert_equal "follicular", svc.phase_for_date(PERIOD_START + 13)
  end

  test "returns ovulation on cycle day 15" do
    svc = service_for
    assert_equal "ovulation", svc.phase_for_date(PERIOD_START + 14)
  end

  test "returns ovulation around day 14 (day 15 of cycle)" do
    svc = service_for
    # Cycle day 15 is classically "around ovulation"
    assert_equal "ovulation", svc.phase_for_date(PERIOD_START + 14)
  end

  test "returns ovulation on cycle day 21" do
    svc = service_for
    assert_equal "ovulation", svc.phase_for_date(PERIOD_START + 20)
  end

  test "returns luteal in the final week (cycle day 22)" do
    svc = service_for
    assert_equal "luteal", svc.phase_for_date(PERIOD_START + 21)
  end

  test "returns luteal on cycle day 28" do
    svc = service_for
    assert_equal "luteal", svc.phase_for_date(PERIOD_START + 27)
  end

  # Full-cycle regression: phases must follow menstrual → follicular →
  # ovulation → luteal in strict order, then wrap back to menstrual on the
  # first day of the next cycle (28-day cycle, 5-day period). Guards the
  # ordering shown on the /symptoms and /superpowers headers.
  test "phases follow the correct sequence across a full cycle and wrap" do
    svc = service_for
    expected = %w[menstrual] * 5 +
      %w[follicular] * 9 +
      %w[ovulation] * 7 +
      %w[luteal] * 7
    assert_equal 28, expected.length

    (0...28).each do |i|
      assert_equal expected[i], svc.phase_for_date(PERIOD_START + i),
        "wrong phase on cycle day #{i + 1}"
    end

    # Next cycle restarts at menstrual (28-day wrap).
    assert_equal "menstrual", svc.phase_for_date(PERIOD_START + 28)
    assert_equal "follicular", svc.phase_for_date(PERIOD_START + 33)
  end

  # --- Short cycle (21 days) with two logged period starts ---

  test "handles 21-day cycle: menstrual on day 1" do
    p2 = PERIOD_START + 21
    svc = service_for(period_start_dates: [PERIOD_START, p2])
    assert_equal "menstrual", svc.phase_for_date(PERIOD_START)
  end

  test "handles 21-day cycle: follicular on day 6" do
    p2 = PERIOD_START + 21
    svc = service_for(period_start_dates: [PERIOD_START, p2])
    assert_equal "follicular", svc.phase_for_date(PERIOD_START + 5)
  end

  test "handles 21-day cycle: ovulation starts on day 8" do
    p2 = PERIOD_START + 21
    svc = service_for(period_start_dates: [PERIOD_START, p2])
    assert_equal "ovulation", svc.phase_for_date(PERIOD_START + 7)
  end

  test "handles 21-day cycle: luteal in final week (day 15)" do
    p2 = PERIOD_START + 21
    svc = service_for(period_start_dates: [PERIOD_START, p2])
    assert_equal "luteal", svc.phase_for_date(PERIOD_START + 14)
  end

  # --- Long cycle (35 days) with two logged period starts ---

  test "handles 35-day cycle: follicular extends to day 21" do
    p2 = PERIOD_START + 35
    svc = service_for(period_start_dates: [PERIOD_START, p2])
    assert_equal "follicular", svc.phase_for_date(PERIOD_START + 20)
  end

  test "handles 35-day cycle: ovulation starts on day 22" do
    p2 = PERIOD_START + 35
    svc = service_for(period_start_dates: [PERIOD_START, p2])
    assert_equal "ovulation", svc.phase_for_date(PERIOD_START + 21)
  end

  test "handles 35-day cycle: luteal starts on day 29" do
    p2 = PERIOD_START + 35
    svc = service_for(period_start_dates: [PERIOD_START, p2])
    assert_equal "luteal", svc.phase_for_date(PERIOD_START + 28)
  end

  # --- Irregular cycles: actual gaps between logged starts ---

  test "uses actual gap between two logged period starts for phase" do
    p2 = PERIOD_START + 31 # irregular 31-day cycle
    svc = service_for(period_start_dates: [PERIOD_START, p2],
      cycle_length: 28) # cycle_length is ignored when logged starts exist
    # 31-day cycle: gap-14 = 17, gap-14+7 = 24
    # menstrual: days 1-5, follicular: 6-17, ovulation: 18-24, luteal: 25-31
    assert_equal "menstrual", svc.phase_for_date(PERIOD_START)
    assert_equal "menstrual", svc.phase_for_date(PERIOD_START + 4)
    assert_equal "follicular", svc.phase_for_date(PERIOD_START + 5)
    assert_equal "follicular", svc.phase_for_date(PERIOD_START + 16)
    assert_equal "ovulation", svc.phase_for_date(PERIOD_START + 17)
    assert_equal "ovulation", svc.phase_for_date(PERIOD_START + 23)
    assert_equal "luteal", svc.phase_for_date(PERIOD_START + 24)
    assert_equal "luteal", svc.phase_for_date(PERIOD_START + 30)
  end

  test "handles multiple irregular cycles in sequence" do
    p1 = Date.new(2026, 1, 1)   # Jan 1
    p2 = Date.new(2026, 1, 28)  # 27-day cycle
    p3 = Date.new(2026, 3, 3)   # 34-day cycle
    p4 = Date.new(2026, 3, 27)  # 24-day cycle
    svc = service_for(period_start_dates: [p1, p2, p3, p4])

    # Between p1 and p2 (27-day cycle): gap-14=13, gap-14+7=20
    assert_equal "follicular", svc.phase_for_date(p1 + 12) # day 13
    assert_equal "ovulation", svc.phase_for_date(p1 + 13) # day 14
    assert_equal "luteal", svc.phase_for_date(p1 + 20) # day 21

    # Between p2 and p3 (34-day cycle): gap-14=20, gap-14+7=27
    assert_equal "follicular", svc.phase_for_date(p2 + 19) # day 20
    assert_equal "ovulation", svc.phase_for_date(p2 + 20) # day 21
    assert_equal "luteal", svc.phase_for_date(p2 + 27) # day 28

    # Between p3 and p4 (24-day cycle): gap-14=10, gap-14+7=17
    assert_equal "follicular", svc.phase_for_date(p3 + 9)  # day 10
    assert_equal "ovulation", svc.phase_for_date(p3 + 10) # day 11
    assert_equal "luteal", svc.phase_for_date(p3 + 17) # day 18
  end

  # --- Forward prediction with rolling average ---

  test "predicts forward from last logged start using rolling average" do
    p1 = Date.new(2026, 1, 1)
    p2 = Date.new(2026, 1, 29) # 28 days
    p3 = Date.new(2026, 2, 26) # 28 days
    p4 = Date.new(2026, 3, 27) # 29 days # ≈ 28
    svc = service_for(period_start_dates: [p1, p2, p3, p4])

    # Dates after p4 should use predicted gap ≈ 28
    d1 = p4 + 14 # predicted cycle day 15 → ovulation
    assert_equal "ovulation", svc.phase_for_date(d1)

    d2 = p4 + 21 # predicted cycle day 22 → luteal
    assert_equal "luteal", svc.phase_for_date(d2)
  end

  test "predicted dates have predicted: true in month_data" do
    p1 = Date.new(2026, 1, 1)
    p2 = Date.new(2026, 1, 29)
    svc = service_for(period_start_dates: [p1, p2])

    # Dates in the cycle after p2 are predicted
    data = svc.month_data(2026, 2)
    feb1 = data.find { |d| d[:date] == Date.new(2026, 2, 1) }
    assert feb1[:predicted]
    # Dates in January (between p1 and p2) are not predicted
    jan_data = svc.month_data(2026, 1)
    jan15 = jan_data.find { |d| d[:date] == Date.new(2026, 1, 15) }
    assert_not jan15[:predicted]
  end

  test "uses user cycle_length as fallback when no period_starts exist" do
    svc = service_for(cycle_length: 35, period_start_dates: [PERIOD_START])
    # Only one period start, no actual gaps → falls back to cycle_length 35
    assert_equal "follicular", svc.phase_for_date(PERIOD_START + 20)
    assert_equal "ovulation", svc.phase_for_date(PERIOD_START + 21)
  end

  # --- month_data ---

  test "month_data returns one entry per day in the month" do
    svc = service_for
    data = svc.month_data(2026, 1)
    assert_equal 31, data.length
  end

  test "month_data returns 28 entries for February 2026" do
    svc = service_for
    data = svc.month_data(2026, 2)
    assert_equal 28, data.length
  end

  test "month_data entry contains expected keys" do
    svc = service_for
    entry = svc.month_data(2026, 1).first
    assert entry.key?(:date)
    assert entry.key?(:phase)
    assert entry.key?(:season)
    assert entry.key?(:colour)
    assert entry.key?(:cycle_day)
    assert entry.key?(:predicted)
  end

  test "month_data first entry has cycle_day 1 when period starts on the 1st" do
    svc = service_for
    entry = svc.month_data(2026, 1).first
    assert_equal 1, entry[:cycle_day]
  end

  test "month_data returns empty array when last_period_start is nil" do
    svc = service_for(last_period_start: nil, period_start_dates: [])
    assert_equal [], svc.month_data(2026, 1)
  end

  # --- colour_for_date ---

  test "colour_for_date returns hex colour for menstrual phase" do
    svc = service_for
    colour = svc.colour_for_date(PERIOD_START)
    assert_match(/\A#[0-9a-fA-F]{6}\z/, colour)
    assert_equal "#933a35", colour
  end

  test "colour_for_date returns hex colour for follicular phase" do
    svc = service_for
    colour = svc.colour_for_date(PERIOD_START + 5)
    assert_equal "#899884", colour
  end

  test "colour_for_date returns hex colour for ovulation phase" do
    svc = service_for
    colour = svc.colour_for_date(PERIOD_START + 14)
    assert_equal "#50715b", colour
  end

  test "colour_for_date returns hex colour for luteal phase" do
    svc = service_for
    colour = svc.colour_for_date(PERIOD_START + 21)
    assert_equal "#D18D84", colour
  end

  # --- short cycle_length + long period_length → no negative wheel arcs ---

  test "wheel_arcs never produces negative day counts" do
    # cycle_length=7, period_length=10 would be pathological
    svc = service_for(cycle_length: 7, period_length: 10, period_start_dates: [PERIOD_START])
    arcs = svc.wheel_arcs
    arcs.each do |arc|
      assert arc[:days] >= 1, "negative day count in wheel_arc: #{arc.inspect}"
      assert arc[:end_angle] >= arc[:start_angle], "negative span in wheel_arc: #{arc.inspect}"
    end
  end

  test "wheel_arcs total equals 4 slices for non-hormonal" do
    svc = service_for
    arcs = svc.wheel_arcs
    assert_equal 4, arcs.length
    phases = arcs.pluck(:phase)
    assert_equal %w[menstrual follicular ovulation luteal], phases
  end

  test "wheel_arcs collapses to 2 slices for hormonal BC" do
    svc = service_for(uses_hormonal_birth_control: true, contraception_type: "pill")
    arcs = svc.wheel_arcs
    assert_equal 2, arcs.length
    phases = arcs.pluck(:phase)
    assert_equal %w[menstrual follicular], phases
  end
end
