class SupportMailer < ApplicationMailer
  default to: ENV.fetch("SUPPORT_EMAIL", "info@season.vision"),
    from: "Season App <#{ENV.fetch("RESEND_FROM_EMAIL", "info@season.vision")}>"

  def support_request(feedback)
    @feedback = feedback
    @user = feedback.user
    mail(
      subject: "[Season Support] #{@feedback.message.truncate(60)}",
      reply_to: @user.email
    )
  end
end
