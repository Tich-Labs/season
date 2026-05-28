class ForecastController < ApplicationController
  def index
    @selected_date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
    @cycle_day = current_user.current_cycle_day(@selected_date) || 1
    @phase = current_user.current_phase || "menstrual"
    @phase_colour = CycleDayContent.phase_colour(@cycle_day)
    @cards = CycleDayContent.for_forecast(@cycle_day)
    @events = current_user.calendar_events.where(date: @selected_date).order(:start_time)
    @has_tracking = current_user.last_period_start.present?
  end
end
