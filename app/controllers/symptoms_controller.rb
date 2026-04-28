class SymptomsController < ApplicationController
  include Streakable

  def index
    @date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
    @log = current_user.symptom_logs.find_or_initialize_by(date: @date)
    @phase = current_user.current_phase
    @season = CycleCalculatorService::SEASON_NAMES[@phase] if @phase
    @cycle_day = current_user.current_cycle_day
  end

  def show
    @symptom_log = current_user.symptom_logs.find(params[:id])
  end

  def discharge
    @log = current_user.symptom_logs.find_or_initialize_by(date: Time.zone.today)
    @phase = current_user.current_phase
  end

  def create
    @log = current_user.symptom_logs.find_or_initialize_by(
      date: symptom_params[:date] || Time.zone.today
    )

    if @log.update(symptom_params)
      update_streak!
      render json: {status: "ok"}
    else
      render json: {errors: @log.errors.full_messages}, status: :unprocessable_content
    end
  end

  private

  def symptom_params
    params.expect(
      symptom_log: [:date, :mood, :energy, :sleep, :physical,
        :mental, :pain, :cravings, :discharge, :notes,
        :sexual_intercourse, :temperature, :weight]
    )
  end
end
