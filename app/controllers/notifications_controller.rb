class NotificationsController < ApplicationController
  before_action :set_notification, only: [:show, :mark_read, :destroy]

  def index
    @notifications = current_user.notifications.recent.page(params[:page]).per(20)
    @unread_count = current_user.notifications.unread.count
  end

  def show
    @notification.mark_as_read unless @notification.read?
  end

  def mark_read
    @notification.mark_as_read
    redirect_to notifications_path, notice: t(".success")
  end

  def destroy
    @notification.destroy
    redirect_to notifications_path, status: :see_other, notice: t(".deleted")
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end
end
