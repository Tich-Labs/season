class TrackingController < ApplicationController
  include Authentication

  before_action :require_onboarding_completed

  def index
    @date = Time.zone.today
    @phase = current_user.current_phase
    @meta = CycleCalculatorService::PHASE_META[@phase]
    @cycle_day = current_user.current_cycle_day
    @streak = current_user.streak&.current_streak || 0

    if current_user.last_period_start
      svc = CycleCalculatorService.new(current_user)
      @strip = svc.strip_data(past_days: 6, future_days: 6)
      @arcs = svc.wheel_arcs
    end
  end

  def create
    if params[:period_start]
      current_user.update!(last_period_start: Time.zone.today)

      cycle_day = current_user.current_cycle_day || 1

      current_user.cycle_entries.create!(
        date: Time.zone.today,
        phase: "menstrual",
        season_name: "Winter",
        cycle_day: cycle_day,
        period_start: true
      )

      redirect_to tracking_index_path, notice: "Period logged! Day #{cycle_day}"
    end
  end
end
