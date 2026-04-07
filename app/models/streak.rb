class Streak < ApplicationRecord
  belongs_to :user
  MILESTONES = [30, 50, 75, 100, 125].freeze

  def increment_streak!
    today = Date.today
    if last_tracked_date == today - 1.day
      self.current_streak = current_streak.to_i + 1
    elsif last_tracked_date == today
      return
    else
      self.current_streak = 1
    end
    self.longest_streak = [longest_streak.to_i,
      current_streak].max
    self.total_flames = total_flames.to_i + 1
    self.last_tracked_date = today
    save!
  end

  def next_milestone
    MILESTONES.find { |m| m > current_streak.to_i }
  end

  def milestone_reached?
    MILESTONES.include?(current_streak.to_i)
  end
end
