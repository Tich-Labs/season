class TrackingController < ApplicationController
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

  def period
    @phase = current_user.current_phase
    @phase_col = CycleCalculatorService::PHASE_META[@phase]&.dig(:colour) || "#933a35"
    @existing = current_user.last_period_start

    if params[:save] == "1" && params[:date].present?
      date = Date.parse(params[:date])
      current_user.update!(last_period_start: date)
      current_user.cycle_entries.where(period_start: true, date: date).destroy_all
      current_user.cycle_entries.create!(
        date: date,
        phase: "menstrual",
        season_name: "Winter",
        cycle_day: 1,
        period_start: true
      )
      redirect_to tracking_index_path, notice: t("tracking.period_update.saved")
      return
    end

    @selected = if params[:selected_date]
      Date.parse(params[:selected_date])
    elsif params[:date]
      Date.parse(params[:date])
    else
      @existing || Time.zone.today
    end

    @month = Date.new(@selected.year, @selected.month, 1)
  end

  def period_update
    date_param = params.dig(:period, :date)
    if date_param.present?
      date = Date.parse(date_param)
      current_user.update!(last_period_start: date)

      # Remove any existing period_start cycle entry for this date then re-create
      current_user.cycle_entries.where(period_start: true, date: date).destroy_all
      current_user.cycle_entries.create!(
        date: date,
        phase: "menstrual",
        season_name: "Winter",
        cycle_day: 1,
        period_start: true
      )

      redirect_to tracking_index_path, notice: t(".saved")
    else
      redirect_to period_tracking_index_path, alert: t(".date_required")
    end
  end
end
