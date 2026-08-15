class SymptomsController < ApplicationController
  include Streakable

  after_action :verify_authorized, only: [:show]

  def index
    @date = begin
      params[:date].present? ? Date.iso8601(params[:date]) : Time.zone.today
    rescue ArgumentError, TypeError
      Time.zone.today
    end
    @log = current_user.symptom_logs.find_or_initialize_by(date: @date)
    # Previous day's log — used to pre-fill sleep / temperature / weight as
    # a starting point when today's log has no value yet (carry-over).
    @prev_log = current_user.symptom_logs.find_by(date: @date - 1)
    @phase = current_user.current_phase
    @season = @phase ? CycleCalculatorService::SEASON_NAMES[@phase] : ""
    @cycle_day = current_user.current_cycle_day
  end

  def show
    @symptom_log = current_user.symptom_logs.find(params[:id])
    authorize @symptom_log
    @phase = current_user.current_phase
    @phase_colour = CycleCalculatorService::PHASE_META[@phase]&.dig(:colour) || "#933a35"
  end

  def discharge
    @log = current_user.symptom_logs.find_or_initialize_by(date: Time.zone.today)
    @phase = current_user.current_phase
    @season = @phase ? CycleCalculatorService::SEASON_NAMES[@phase] : ""
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

  def log_physical
    log_for_today.record_physical_symptom(params[:symptom_key], params[:value])
    render json: {status: "ok"}
  end

  def log_mental
    log_for_today.record_mental_symptom(params[:symptom_key], params[:value])
    render json: {status: "ok"}
  end

  def log_bleeding
    log_for_today.record_bleeding_flow(params[:flow])
    render json: {status: "ok"}
  end

  private

  def log_for_today
    date = params[:date].presence || Time.zone.today
    current_user.symptom_logs.find_or_initialize_by(date: date)
  end

  def symptom_params
    params.expect(
      symptom_log: [
        :date, :mood, :mood_text, :energy, :sleep, :physical,
        :mental, :pain, :cravings, :discharge, :notes,
        :sexual_intercourse, :intercourse_tags, :temperature, :weight,
        {moods: []}
      ]
    )
  end
end
