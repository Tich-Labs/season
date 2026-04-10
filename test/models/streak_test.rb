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
    @streak.update_columns(current_streak: 10, last_tracked_date: Time.zone.today - 3)
    @streak.increment_streak!
    assert_equal 1, @streak.current_streak
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
end
