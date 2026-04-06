class SuperpowersController < ApplicationController
  before_action :authenticate_user!

  def index
    @superpower_logs = current_user.superpower_logs.includes(:user)
  end

  def show
    @superpower_log = current_user.superpower_logs.find(params[:id])
  end
end
