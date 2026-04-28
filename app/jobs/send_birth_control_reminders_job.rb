class SendBirthControlRemindersJob < ApplicationJob
  queue_as :default

  def perform
    Reminder.active.where(reminder_type: "pill").includes(:user).find_each do |reminder|
      next if reminder.user&.email.blank?
      ReminderMailer.birth_control_reminder(reminder.user).deliver_later
    end
  end
end
