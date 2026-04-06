class DailyViewController < ApplicationController
  before_action :authenticate_user!

  def show
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    @cycle_entry = current_user.cycle_entries.find_by(date: @date)
    @symptom_logs = current_user.symptom_logs.where(date: @date)
    @superpower_logs = current_user.superpower_logs.where(date: @date)
  end
end
