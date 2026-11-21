require "test_helper"

class Streaks::RecomputeServiceTest < ActiveSupport::TestCase
  def setup
    @user = users(:alice)
    @user.streak&.destroy
    @user.symptom_logs.delete_all
    @user.superpower_logs.delete_all
    @user.period_starts.delete_all
    @streak = @user.create_streak!(current_streak: 0, longest_streak: 0, total_flames: 0)
  end

  test "counts consecutive backfilled symptom days as one flame each" do
    (2.days.ago.to_date..Time.zone.today).each do |date|
      @user.symptom_logs.create!(date: date, mood: 3)
    end

    Streaks::RecomputeService.call(user: @user)

    assert_equal 3, @streak.reload.current_streak
    assert_equal 3, @streak.longest_streak
    assert_equal 3, @streak.total_flames
    assert_equal Time.zone.today, @streak.last_tracked_date
  end

  test "counts symptoms, superpowers and period starts on the same day only once" do
    @user.symptom_logs.create!(date: Time.zone.today, mood: 3)
    @user.superpower_logs.create!(date: Time.zone.today, ratings: {"Focused" => 2})
    @user.period_starts.create!(started_on: Time.zone.today)

    Streaks::RecomputeService.call(user: @user)

    assert_equal 1, @streak.reload.current_streak
    assert_equal 1, @streak.total_flames
  end

  test "combines different tracking sources into consecutive days" do
    @user.symptom_logs.create!(date: 2.days.ago.to_date, mood: 3)
    @user.superpower_logs.create!(date: 1.day.ago.to_date, ratings: {"Focused" => 2})
    @user.period_starts.create!(started_on: Time.zone.today)

    Streaks::RecomputeService.call(user: @user)

    assert_equal 3, @streak.reload.current_streak
  end

  test "does not regress a newer streak when an old day is backfilled" do
    @streak.update_columns(current_streak: 5, longest_streak: 5, total_flames: 5, last_tracked_date: Time.zone.today)
    @user.symptom_logs.create!(date: 30.days.ago.to_date, mood: 3)

    Streaks::RecomputeService.call(user: @user)

    assert_equal 5, @streak.reload.current_streak
    assert_equal Time.zone.today, @streak.last_tracked_date
  end

  test "recovers a streak stuck at one when the missing day is backfilled" do
    @streak.update_columns(current_streak: 1, longest_streak: 1, total_flames: 1, last_tracked_date: Time.zone.today)
    @user.symptom_logs.create!(date: 1.day.ago.to_date, mood: 3)
    @user.symptom_logs.create!(date: Time.zone.today, mood: 3)

    Streaks::RecomputeService.call(user: @user)

    assert_equal 2, @streak.reload.current_streak
  end

  test "restarts the streak after a gap that grace cannot cover" do
    travel_to Date.new(2026, 7, 8) do
      @user.symptom_logs.create!(date: Date.new(2026, 7, 5), mood: 3)
      @user.symptom_logs.create!(date: Date.new(2026, 7, 8), mood: 3)

      Streaks::RecomputeService.call(user: @user)

      assert_equal 1, @streak.reload.current_streak
      assert_equal 2, @streak.total_flames
    end
  end

  test "forgives one missed non-rest day per week" do
    travel_to Date.new(2026, 7, 8) do
      @user.symptom_logs.create!(date: Date.new(2026, 7, 6), mood: 3)
      @user.symptom_logs.create!(date: Date.new(2026, 7, 8), mood: 3)

      Streaks::RecomputeService.call(user: @user)

      assert_equal 2, @streak.reload.current_streak
      assert_equal Date.new(2026, 7, 6), @streak.grace_week
      assert_equal 1, @streak.grace_used
    end
  end
end
