class CalendarEventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized, only: [:show, :edit, :update, :destroy]

  def index
    redirect_to forecast_path
  end

  def show
  end

  def new
    @event = current_user.calendar_events.build(
      date: params[:date] || Time.zone.today
    )
    @period_ranges = period_ranges_json
  end

  def edit
    @period_ranges = period_ranges_json
  end

  def create
    @event = current_user.calendar_events.build(event_params)
    if @event.save
      redirect_to forecast_path, notice: t(".created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @event.update(event_params)
      redirect_to forecast_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @event.destroy
    redirect_to forecast_path, notice: t(".deleted")
  end

  private

  def set_event
    @event = current_user.calendar_events.find(params[:id])
    authorize @event
  end

  def event_params
    params.expect(
      calendar_event: [:title, :date, :end_date, :start_time, :end_time, :category, :notes, :location, :guests, :reminder_minutes, :repeat_frequency]
    )
  end

  # [[start_date, end_date], ...] for the user's predicted period days, a
  # year out — used client-side to warn before scheduling on a period day.
  def period_ranges_json
    CycleCalculatorService.new(current_user)
      .period_ranges(from: Time.zone.today - 3.months, to: Time.zone.today + 1.year)
      .map { |start_date, end_date| [start_date.iso8601, end_date.iso8601] }
      .to_json
  end
end
