class WeeklyFeedbackMailer < ApplicationMailer
  default to: -> { ENV["TRELLO_EMAIL"] || ENV["ADMIN_EMAIL"] || "admin@season.app" }

  def summary(response)
    @response = response
    @question = response.weekly_feedback_question
    @user = response.user
    mail(
      subject: "[Week #{response.week_number}] #{@question.question_type.titleize}: #{@user.email}",
      from: "weekly-feedback@season.app"
    )
  end
end
