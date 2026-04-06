class TrackingController < ApplicationController
  before_action :authenticate_user!

  def index
    @tracking = current_user.cycle_entries.includes(:symptoms)
  end
end
