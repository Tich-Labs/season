class TrackingController < ApplicationController
  include Authentication

  before_action :require_onboarding_completed

  def index
    @date = Date.today
    @phase = current_user.current_phase
    @season = CycleCalculatorService::SEASON_NAMES[@phase] if @phase
    @cycle_day = current_user.current_cycle_day
    @symptom_log = current_user.symptom_logs.find_by(date: @date)
    @streak = current_user.streak&.current_streak || 0
  end

  def create
    if params[:period_start]
      current_user.update!(last_period_start: Date.today)

      cycle_day = current_user.current_cycle_day || 1

      current_user.cycle_entries.create!(
        date: Date.today,
        phase: "menstrual",
        season_name: "Winter",
        cycle_day: cycle_day,
        period_start: true
      )

      redirect_to tracking_index_path, notice: "Period logged! Day #{cycle_day}"
    end
  end
end
