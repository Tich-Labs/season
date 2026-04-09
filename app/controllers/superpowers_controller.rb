class SuperpowersController < ApplicationController
  before_action :authenticate_user
  before_action :require_onboarding_completed

  SUPERPOWERS = {
    "menstrual" => [
      "Deep intuition", "Inner clarity",
      "Rest and restore", "Dreaming",
      "Introspection"
    ],
    "follicular" => [
      "Creativity", "Planning",
      "Starting new projects", "Learning",
      "Fresh ideas", "Optimism"
    ],
    "ovulation" => [
      "Communication", "Confidence",
      "Leadership", "Social energy",
      "Problem solving", "Magnetism"
    ],
    "luteal" => [
      "Rizz Game", "Spatial thinking",
      "Develop projects", "Execute projects",
      "Idea-rich", "Creativity",
      "Comprehension", "Eloquent",
      "Drive", "Talkative",
      "Self-confidence", "Positivity"
    ]
  }.freeze

  def index
    @date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
    @phase = current_user&.current_phase || "follicular"
    @superpowers = SUPERPOWERS[@phase] || SUPERPOWERS["follicular"]
    @superpower_logs = current_user&.superpower_logs&.order(date: :desc)&.limit(10) || []
    @log = current_user&.superpower_logs&.find_or_initialize_by(date: @date)
    @ratings = @log&.ratings || {}
  end

  def create
    ratings_params = params[:ratings] || {}
    @log = current_user.superpower_logs.find_or_initialize_by(
      date: params[:date] || Time.zone.today
    )
    current_ratings = @log.ratings || {}
    new_ratings = current_ratings.merge(ratings_params.transform_values(&:to_i))
    if @log.update(ratings: new_ratings)
      update_streak!
      head :ok
    else
      head :unprocessable_content
    end
  end

  private

  def superpower_params
    params.expect(superpower_log: [:date, :ratings, :notes])
  end

  def update_streak!
    streak = current_user.streak || current_user.create_streak(
      current_streak: 0,
      longest_streak: 0,
      total_flames: 0
    )
    streak.increment_streak!
  end
end
