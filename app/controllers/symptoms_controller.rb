class SymptomsController < ApplicationController
  include Authentication

  before_action :require_onboarding_completed

  def index
    @date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
    @log = current_user.symptom_logs.find_or_initialize_by(date: @date)
    @phase = current_user.current_phase
    @season = CycleCalculatorService::SEASON_NAMES[@phase] if @phase
  end

  def create
    @log = current_user.symptom_logs.find_or_initialize_by(
      date: symptom_params[:date] || Time.zone.today
    )

    if @log.update(symptom_params)
      update_streak!
      render json: {status: "ok"}
    else
      render json: {errors: @log.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private

  def symptom_params
    params.require(:symptom_log).permit(
      :date, :mood, :energy, :sleep, :physical,
      :mental, :pain, :cravings, :discharge, :notes,
      :sexual_intercourse
    )
  end

  def update_streak!
    streak = current_user.streak || current_user.create_streak
    streak.increment_streak!
  end
end
