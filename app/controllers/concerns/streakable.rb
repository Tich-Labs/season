module Streakable
  extend ActiveSupport::Concern

  private

  def update_streak!
    streak = current_user.streak || current_user.build_streak(
      current_streak: 0,
      longest_streak: 0,
      total_flames: 0
    )
    streak.increment_streak!
  end
end
