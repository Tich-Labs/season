class SupportMailer < ApplicationMailer
  default to: ENV.fetch("SUPPORT_EMAIL", "info@season.vision"),
    from: "Season App <#{ENV.fetch("RESEND_FROM_EMAIL", "info@season.vision")}>"

  def support_request(feedback)
    # Delivered to the internal support inbox, so it uses the default locale.
    I18n.with_locale(I18n.default_locale) do
      @feedback = feedback
      @user = feedback.user
      mail(
        subject: t(".subject", message: @feedback.message.truncate(60)),
        reply_to: @user.email
      )
    end
  end
end
