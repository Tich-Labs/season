class SuperpowersController < ApplicationController
  include Streakable

  after_action :verify_authorized, only: [:show]

  SUPERPOWERS = [
    "Spatial reasoning",
    "Developing/planning projects",
    "Executing projects",
    "Imaginative",
    "Creativity",
    "Quick on the uptake",
    "High intellectual capacity",
    "Eloquent",
    "Drive",
    "Talkative",
    "Self-confidence",
    "Positivity",
    "Motivated",
    "Extroverted",
    "Feeling attractive",
    "Good listener",
    "Open to change",
    "Focused",
    "Making decisions is easier",
    "Self-reflective"
  ].freeze

  def index
    @date = begin
      params[:date].present? ? Date.iso8601(params[:date]) : Time.zone.today
    rescue ArgumentError, TypeError
      Time.zone.today
    end
    @phase = CycleCalculatorService.new(current_user).effective_phase_for_date(@date) || "follicular"
    @phase_colour = CycleCalculatorService::PHASE_META[@phase]&.dig(:colour) || "#933a35"
    @superpowers = SUPERPOWERS
    @superpower_logs = current_user.superpower_logs.order(date: :desc).limit(10)
    @log = current_user.superpower_logs.find_or_initialize_by(date: @date)
    @ratings = @log.ratings || {}
  end

  def show
    @superpower_log = current_user.superpower_logs.find(params[:id])
    authorize @superpower_log
    @phase = CycleCalculatorService.new(current_user).effective_phase_for_date(@superpower_log.date)
    @phase_colour = CycleCalculatorService::PHASE_META[@phase]&.dig(:colour) || "#933a35"
  end

  def create
    ratings_params = (params[:ratings] || {}).to_unsafe_h
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
end
