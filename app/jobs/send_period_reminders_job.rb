class SendPeriodRemindersJob < ApplicationJob
  queue_as :default

  def perform
    today = Time.zone.today

    Reminder.active.where(reminder_type: "period_start").includes(:user).find_each do |reminder|
      user = reminder.user
      next unless user&.email.present? && user.last_period_start && user.cycle_length

      advance = reminder.advance_days || 2
      next_start = CycleCalculatorService.new(user).next_period_start
      next unless next_start && (next_start - today).to_i == advance

      ReminderMailer.period_reminder(user, "period_start").deliver_later
    end

    Reminder.active.where(reminder_type: "period_end").includes(:user).find_each do |reminder|
      user = reminder.user
      next unless user&.email.present? && user.last_period_start && user.cycle_length && user.period_length

      advance = reminder.advance_days || 1
      next_end = CycleCalculatorService.new(user).next_period_start + (user.period_length || 5) - 1
      next unless next_end && (next_end - today).to_i == advance

      ReminderMailer.period_reminder(user, "period_end").deliver_later
    end
  end
end
