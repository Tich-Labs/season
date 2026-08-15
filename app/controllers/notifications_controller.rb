class NotificationsController < ApplicationController
  before_action :set_notification, only: [:show, :mark_read, :destroy]
  after_action :verify_authorized, only: [:show, :mark_read, :destroy]

  def index
    # The view renders a plain list with no page-link controls, so this just
    # caps it rather than paginating — `.page`/`.per` is Kaminari's API and
    # this app uses pagy (which needs an explicit `pagy(...)` call plus nav
    # markup neither of which exist here), so that call raised a 500 on
    # every visit to this page.
    @notifications = current_user.notifications.recent.limit(20)
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
    authorize @notification
  end
end
