class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :require_admin

  private

  def require_admin
    redirect_to root_path unless authenticated? && current_user.admin?
  end
end
