module Streakable
  extend ActiveSupport::Concern

  private

  # Records a tracking action for the streak.
  #
  # Today's entries advance the streak directly. Backfilled entries rebuild it
  # from the user's actual tracking dates, so logging several past days in one
  # sitting counts each consecutive day instead of leaving the flame at 1.
  # Future dates are ignored.
  def update_streak!(on = Time.zone.today)
    on = on.to_date
    return if on > Time.zone.today

    if on < Time.zone.today
      Streaks::RecomputeService.call(user: current_user)
      return
    end

    streak = current_user.streak || current_user.build_streak(
      current_streak: 0,
      longest_streak: 0,
      total_flames: 0
    )
    streak.increment_streak!(on: on)
  end
end
