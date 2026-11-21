class SendMorningRemindersJob < ApplicationJob
  queue_as :default

  def perform
    Reminder.active.where(reminder_type: "morning").includes(:user).find_each do |reminder|
      next if reminder.user&.email.blank?
      ReminderMailer.morning_summary(reminder.user).deliver_later
      with_user_locale(reminder.user) do
        PushNotificationService.send_to_user(reminder.user,
          title: I18n.t("push_notifications.morning.title"),
          body: I18n.t("push_notifications.morning.body"),
          url: "/daily/#{Time.zone.today}")
      end
    end
  end
end
