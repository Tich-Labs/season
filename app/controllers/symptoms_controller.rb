class SymptomsController < ApplicationController
  before_action :authenticate_user!

  def index
    @symptom_logs = current_user.symptom_logs.includes(:user)
  end

  def show
    @symptom_log = current_user.symptom_logs.find(params[:id])
  end
end
