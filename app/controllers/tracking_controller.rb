class TrackingController < ApplicationController
  def index
    @date = begin
      params[:date].present? ? Date.iso8601(params[:date]) : Time.zone.today
    rescue ArgumentError, TypeError
      Time.zone.today
    end
    @phase = current_user.current_phase
    @meta = CycleCalculatorService::PHASE_META[@phase] || {}
    @cycle_day = current_user.current_cycle_day
    @streak = current_user.streak&.current_streak || 0

    if current_user.last_period_start
      svc = CycleCalculatorService.new(current_user)
      @cycle_day = current_user.current_cycle_day(@date)
      @strip = svc.strip_data(past_days: 6, future_days: 6, center: @date)
      @arcs = svc.wheel_arcs
      @phase = svc.effective_phase_for_date(@date)
      @meta = CycleCalculatorService::PHASE_META[@phase] || {}
    end
  end

  def create
    if params[:period_start]
      today = Time.zone.today
      ApplicationRecord.transaction do
        current_user.update!(last_period_start: today)
        current_user.period_starts.find_or_create_by!(started_on: today)
      end

      cycle_day = current_user.current_cycle_day || 1

      current_user.cycle_entries.create!(
        date: today,
        phase: "menstrual",
        season_name: "Winter",
        cycle_day: cycle_day,
        period_start: true
      )

      redirect_to tracking_index_path(tracking_saved: 1), notice: "Period logged! Day #{cycle_day}"
    end
  end

  def period
    @phase = current_user.current_phase
    @phase_col = CycleCalculatorService::PHASE_META[@phase]&.dig(:colour) || "#933a35"
    @existing = current_user.last_period_start
    @period_end = current_user.last_period_end

    @month = begin
      params[:date].present? ? Date.iso8601(params[:date]) : (@existing || Time.zone.today)
    rescue ArgumentError, TypeError
      @existing || Time.zone.today
    end
    @month = Date.new(@month.year, @month.month, 1)
  end

  def period_update
    start_param = params[:last_period_start]
    if start_param.blank?
      redirect_to period_tracking_index_path, alert: t(".date_required") and return
    end

    begin
      start_date = Date.iso8601(start_param)
      end_date = params[:last_period_end].presence && Date.iso8601(params[:last_period_end])
    rescue ArgumentError, TypeError
      redirect_to period_tracking_index_path, alert: t(".invalid_date") and return
    end

    if end_date && end_date < start_date
      redirect_to period_tracking_index_path, alert: t(".end_before_start") and return
    end

    ApplicationRecord.transaction do
      current_user.update!(last_period_start: start_date, last_period_end: end_date)
      current_user.period_starts.find_or_create_by!(started_on: start_date)
    end

    # Remove any existing period_start cycle entry for this date then re-create
    current_user.cycle_entries.where(period_start: true, date: start_date).destroy_all
    current_user.cycle_entries.create!(
      date: start_date,
      phase: "menstrual",
      season_name: "Winter",
      cycle_day: 1,
      period_start: true
    )

    redirect_to tracking_index_path(tracking_saved: 1), notice: t(".saved")
  end
end
