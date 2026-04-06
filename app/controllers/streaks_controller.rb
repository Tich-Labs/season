class StreaksController < ApplicationController
  before_action :authenticate_user!

  def index
    @streaks = current_user.streaks
  end
end
