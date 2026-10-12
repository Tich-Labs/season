module Streakable
  extend ActiveSupport::Concern

  private

  # Records a tracking action for the streak.
  #
  # Only *today's* activity counts: a save backdated to a past day (e.g. the
  # user filling in yesterday via the date drum) must not advance today's
  # streak, so past/future dates are ignored. Callers pass the saved entry's
  # date; anything that isn't today is a no-op.
  def update_streak!(on = Time.zone.today)
    on = on.to_date
    return unless on == Time.zone.today

    streak = current_user.streak || current_user.build_streak(
      current_streak: 0,
      longest_streak: 0,
      total_flames: 0
    )
    streak.increment_streak!(on: on)
  end
end
