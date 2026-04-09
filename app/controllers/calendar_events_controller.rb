class CalendarEventsController < ApplicationController
  before_action :set_event, only: [:edit, :update, :destroy]

  def new
    @event = current_user.calendar_events.build(
      date: params[:date] || Time.zone.today
    )
  end

  def edit
  end

  def create
    @event = current_user.calendar_events.build(event_params)
    if @event.save
      redirect_to calendar_path, notice: t(".created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @event.update(event_params)
      redirect_to calendar_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @event.destroy
    redirect_to calendar_path, notice: t(".deleted")
  end

  private

  def set_event
    @event = current_user.calendar_events.find(params[:id])
  end

  def event_params
    params.expect(
      calendar_event: [:title, :date, :start_time, :end_time, :category, :notes]
    )
  end
end
