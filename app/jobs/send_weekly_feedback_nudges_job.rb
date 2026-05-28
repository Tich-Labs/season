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

        PushNotificationService.send_to_user(
          user,
          title: "How was Week #{week}?",
          body: "Share your experience with Season — your feedback helps us improve.",
          url: "/tracking"
        )
    end
  end
end
