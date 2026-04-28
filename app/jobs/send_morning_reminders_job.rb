class SendMorningRemindersJob < ApplicationJob
  queue_as :default

  def perform
    Reminder.active.where(reminder_type: "morning").includes(:user).find_each do |reminder|
      next if reminder.user&.email.blank?
      ReminderMailer.morning_summary(reminder.user).deliver_later
    end
  end
end
