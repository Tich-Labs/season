require "test_helper"

class StreakTest < ActiveSupport::TestCase
  def setup
    @user = users(:alice)
    # Remove fixture streak so tests start clean
    @user.streak&.destroy
    @streak = Streak.create!(user: @user, current_streak: 0, longest_streak: 0, total_flames: 0)
  end

  def teardown
    @streak.destroy
  end

  # --- increment_streak! ---

  test "sets current_streak to 1 on first use (nil last_tracked_date)" do
    assert_nil @streak.last_tracked_date
    @streak.increment_streak!
    assert_equal 1, @streak.current_streak
    assert_equal Time.zone.today, @streak.last_tracked_date
  end

  test "increments streak on consecutive days" do
    @streak.update_columns(current_streak: 3, last_tracked_date: Time.zone.today - 1)
    @streak.increment_streak!
    assert_equal 4, @streak.current_streak
  end

  test "resets to 1 after a missed day" do
    travel_to Date.new(2026, 7, 8) do # Wednesday; missed Mon 6 + Tue 7 in the same week
      @streak.update_columns(current_streak: 10, last_tracked_date: Date.new(2026, 7, 5))
      @streak.increment_streak!
      assert_equal 1, @streak.current_streak
    end
  end

  test "does not double-increment when called twice on same day" do
    @streak.update_columns(current_streak: 5, last_tracked_date: Time.zone.today)
    @streak.increment_streak!
    assert_equal 5, @streak.current_streak
  end

  test "updates longest_streak when current exceeds it" do
    @streak.update_columns(current_streak: 9, longest_streak: 9, last_tracked_date: Time.zone.today - 1)
    @streak.increment_streak!
    assert_equal 10, @streak.longest_streak
  end

  test "increments total_flames on each new tracking day" do
    @streak.update_columns(total_flames: 7, last_tracked_date: Time.zone.today - 1)
    @streak.increment_streak!
    assert_equal 8, @streak.total_flames
  end

  test "does not increment total_flames when same-day double call" do
    @streak.update_columns(total_flames: 7, last_tracked_date: Time.zone.today)
    @streak.increment_streak!
    assert_equal 7, @streak.total_flames
  end

  # --- next_milestone ---

  test "next_milestone returns the lowest milestone above current streak" do
    @streak.current_streak = 20
    assert_equal 30, @streak.next_milestone
  end

  test "next_milestone returns 30 when streak is 0" do
    @streak.current_streak = 0
    assert_equal 30, @streak.next_milestone
  end

  test "next_milestone returns 50 when streak is 30" do
    @streak.current_streak = 30
    assert_equal 50, @streak.next_milestone
  end

  test "next_milestone returns nil when streak exceeds all milestones" do
    @streak.current_streak = 200
    assert_nil @streak.next_milestone
  end

  # --- milestone_reached? ---

  test "milestone_reached? returns true when streak equals a milestone" do
    @streak.current_streak = 30
    assert @streak.milestone_reached?
  end

  test "milestone_reached? returns false when streak does not equal a milestone" do
    @streak.current_streak = 15
    assert_not @streak.milestone_reached?
  end

  # --- Forgiveness (grace + rest days) ---

  test "forgives a single missed non-rest day using the weekly grace" do
    travel_to Date.new(2026, 7, 8) do # Wednesday, week starts Mon 6 Jul
      @streak.update_columns(current_streak: 10, last_tracked_date: Date.new(2026, 7, 6))
      @streak.increment_streak!
      assert_equal 11, @streak.current_streak
      assert_equal Date.new(2026, 7, 6), @streak.grace_week
      assert_equal 1, @streak.grace_used
    end
  end

  test "resets when more than one non-rest day is missed in the same week" do
    travel_to Date.new(2026, 7, 8) do
      @streak.update_columns(current_streak: 10, last_tracked_date: Date.new(2026, 7, 5)) # Sun
      @streak.increment_streak!
      assert_equal 1, @streak.current_streak
      assert_nil @streak.grace_week
      assert_equal 0, @streak.grace_used
    end
  end

  test "forgives missed days that straddle a week boundary, one per week" do
    travel_to Date.new(2026, 7, 7) do # Tuesday, week starts Mon 6 Jul
      # Missed: Sunday 5 Jul (prev week) + Monday 6 Jul (this week).
      @streak.update_columns(current_streak: 5, last_tracked_date: Date.new(2026, 7, 4))
      @streak.increment_streak!
      assert_equal 6, @streak.current_streak
      assert_equal Date.new(2026, 7, 6), @streak.grace_week
      assert_equal 1, @streak.grace_used
    end
  end

  test "grace is available again in a new week" do
    travel_to Date.new(2026, 7, 8) do
      @streak.update_columns(current_streak: 10, last_tracked_date: Date.new(2026, 7, 6))
      @streak.increment_streak!
      assert_equal 11, @streak.current_streak
    end
    travel_to Date.new(2026, 7, 15) do # next Wednesday
      @streak.update_columns(last_tracked_date: Date.new(2026, 7, 13))
      @streak.increment_streak!
      assert_equal 12, @streak.current_streak
      assert_equal Date.new(2026, 7, 13), @streak.grace_week
      assert_equal 1, @streak.grace_used
    end
  end

  test "forgives missed days inside a tracked period without spending grace" do
    @user.period_starts.create!(started_on: Time.zone.today - 4)
    @streak.update_columns(current_streak: 10, last_tracked_date: Time.zone.today - 3)
    @streak.increment_streak!
    assert_equal 11, @streak.current_streak
    assert_nil @streak.grace_week
    assert_equal 0, @streak.grace_used
  end

  test "ignores out-of-order (backdated) increments" do
    @streak.update_columns(current_streak: 5, last_tracked_date: Time.zone.today)
    @streak.increment_streak!(on: Time.zone.today - 1)
    assert_equal 5, @streak.current_streak
    assert_equal Time.zone.today, @streak.last_tracked_date
  end

  # --- current_value (effective display value) ---

  test "current_value returns 0 when never tracked" do
    assert_equal 0, @streak.current_value
  end

  test "current_value returns stored streak when tracked today" do
    @streak.update_columns(current_streak: 5, last_tracked_date: Time.zone.today)
    assert_equal 5, @streak.current_value
  end

  test "current_value returns stored streak when tracked yesterday" do
    @streak.update_columns(current_streak: 5, last_tracked_date: Time.zone.today - 1)
    assert_equal 5, @streak.current_value
  end

  test "current_value returns stored streak when the missed day is forgivable" do
    @streak.update_columns(current_streak: 5, last_tracked_date: Time.zone.today - 2)
    assert_equal 5, @streak.current_value
    assert_equal 0, @streak.grace_used # a read must never mutate the streak
  end

  test "current_value returns 0 when the gap is unforgivable" do
    travel_to Date.new(2026, 7, 8) do # Wednesday; missed Mon 6 + Tue 7 in the same week
      @streak.update_columns(current_streak: 5, last_tracked_date: Date.new(2026, 7, 5))
      assert_equal 0, @streak.current_value
    end
  end

  test "current_value returns stored streak when all missed days are rest days" do
    @user.period_starts.create!(started_on: Time.zone.today - 4)
    @streak.update_columns(current_streak: 5, last_tracked_date: Time.zone.today - 3)
    assert_equal 5, @streak.current_value
  end
end
