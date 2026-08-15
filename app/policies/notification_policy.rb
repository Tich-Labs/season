class NotificationPolicy < OwnedRecordPolicy
  # NotificationsController#mark_read isn't a standard CRUD action, so Pundit
  # won't infer a policy method for it automatically — route it to the same
  # ownership check as update.
  def mark_read? = update?
end
