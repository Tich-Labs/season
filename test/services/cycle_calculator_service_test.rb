require "test_helper"

class CycleCalculatorServiceTest < ActiveSupport::TestCase
  # Lightweight stub — duck-types all attributes the service reads
  UserStub = Struct.new(:cycle_length, :period_length, :last_period_start,
    :uses_hormonal_birth_control, :contraception_type)

  # Fixed reference date: 1 Jan 2026 (Thursday)
  PERIOD_START = Date.new(2026, 1, 1)

  def service_for(cycle_length: 28, period_length: 5, last_period_start: PERIOD_START,
    uses_hormonal_birth_control: false, contraception_type: "none")
    user = UserStub.new(
      cycle_length: cycle_length,
      period_length: period_length,
      last_period_start: last_period_start,
      uses_hormonal_birth_control: uses_hormonal_birth_control,
      contraception_type: contraception_type
    )
    CycleCalculatorService.new(user)
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

  # --- Short cycle (21 days) ---

  test "handles 21-day cycle: menstrual on day 1" do
    svc = service_for(cycle_length: 21)
    assert_equal "menstrual", svc.phase_for_date(PERIOD_START)
  end

  test "handles 21-day cycle: follicular on day 6" do
    svc = service_for(cycle_length: 21)
    # period_length=5, cycle_length-14=7 → follicular days 6-7
    assert_equal "follicular", svc.phase_for_date(PERIOD_START + 5)
  end

  test "handles 21-day cycle: ovulation starts on day 8" do
    svc = service_for(cycle_length: 21)
    # cycle_length-14+7=14 → ovulation days 8-14
    assert_equal "ovulation", svc.phase_for_date(PERIOD_START + 7)
  end

  test "handles 21-day cycle: luteal in final week (day 15)" do
    svc = service_for(cycle_length: 21)
    assert_equal "luteal", svc.phase_for_date(PERIOD_START + 14)
  end

  # --- Long cycle (35 days) ---

  test "handles 35-day cycle: follicular extends to day 21" do
    svc = service_for(cycle_length: 35)
    # cycle_length-14=21 → follicular days 6-21
    assert_equal "follicular", svc.phase_for_date(PERIOD_START + 20)
  end

  test "handles 35-day cycle: ovulation starts on day 22" do
    svc = service_for(cycle_length: 35)
    assert_equal "ovulation", svc.phase_for_date(PERIOD_START + 21)
  end

  test "handles 35-day cycle: luteal starts on day 29" do
    svc = service_for(cycle_length: 35)
    assert_equal "luteal", svc.phase_for_date(PERIOD_START + 28)
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
  end

  test "month_data first entry has cycle_day 1 when period starts on the 1st" do
    svc = service_for
    entry = svc.month_data(2026, 1).first
    assert_equal 1, entry[:cycle_day]
  end

  test "month_data returns empty array when last_period_start is nil" do
    svc = service_for(last_period_start: nil)
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
    assert_equal "#50705b", colour
  end

  test "colour_for_date returns hex colour for luteal phase" do
    svc = service_for
    colour = svc.colour_for_date(PERIOD_START + 21)
    assert_equal "#D18D83", colour
  end
end
