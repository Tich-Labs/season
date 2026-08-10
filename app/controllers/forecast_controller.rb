class ForecastController < ApplicationController
  def index
    @selected_date = begin
      params[:date].present? ? Date.iso8601(params[:date]) : Time.zone.today
    rescue ArgumentError, TypeError
      Time.zone.today
    end
    @cycle_day = current_user.current_cycle_day(@selected_date) || 1
    service = CycleCalculatorService.new(current_user)
    @phase = service.effective_phase_for_date(@selected_date) || "menstrual"
    @phase_colour = CycleCalculatorService::PHASE_META[@phase][:colour]
    @cards = CycleDayContent.for_forecast(@cycle_day, locale: current_user.language)
    @events = current_user.calendar_events.where(date: @selected_date).order(:start_time)
    @has_tracking = current_user.last_period_start.present? || current_user.period_starts.any?
  end
end
