class SendWeeklyFeedbackNudgesJob < ApplicationJob
  queue_as :default

  def perform
    User.where(onboarding_completed: true)
      .where.not(confirmed_at: nil)
      .find_each do |user|
        week = user.current_feedback_week
        next unless week

        already_completed = user.weekly_feedback_responses
          .exists?(week_number: week)
        next if already_completed

        with_user_locale(user) do
          PushNotificationService.send_to_user(
            user,
            title: I18n.t("push_notifications.weekly_feedback.title", week: week),
            body: I18n.t("push_notifications.weekly_feedback.body"),
            url: "/tracking"
          )
        end
    end
  end
end
