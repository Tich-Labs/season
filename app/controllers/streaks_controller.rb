class StreaksController < ApplicationController
  def index
    @streak = current_user.streak || current_user.create_streak(
      current_streak: 0,
      longest_streak: 0,
      total_flames: 0
    )
    # Display the *effective* value so a broken streak shows 0 immediately,
    # not the stale stored number.
    @current_streak = @streak.current_value
    @milestones = Streak::MILESTONES
    @next_milestone = @milestones.find { |m| m > @current_streak }
    @days_to_next = @next_milestone ? @next_milestone - @current_streak : nil
    @phase = current_user.current_phase
    @phase_colour = CycleCalculatorService::PHASE_META[@phase]&.dig(:colour) || "#933a35"
  end
end
