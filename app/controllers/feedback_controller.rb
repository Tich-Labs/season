class FeedbackController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    # TODO: Store feedback in database or send to external service
    # For now, just redirect back with success message
    redirect_to user_root_path, notice: t(".thank_you")
  end
end
