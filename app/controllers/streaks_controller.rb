class StreaksController < ApplicationController
  include Authentication

  before_action :require_onboarding_completed

  def index
    @streak = current_user.streak || current_user.create_streak(
      current_streak: 0,
      longest_streak: 0,
      total_flames: 0
    )
    @milestones = Streak::MILESTONES
    @next_milestone = @streak.next_milestone
    @days_to_next = @next_milestone ? @next_milestone - @streak.current_streak.to_i : nil
  end
end
