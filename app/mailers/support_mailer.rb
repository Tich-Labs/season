class SupportMailer < ApplicationMailer
  default to: "info@season.vision",
    from: "Season App <info@season.vision>"

  def support_request(feedback)
    @feedback = feedback
    @user = feedback.user
    mail(
      subject: "[Season Support] #{@feedback.message.truncate(60)}",
      reply_to: @user.email
    )
  end
end
