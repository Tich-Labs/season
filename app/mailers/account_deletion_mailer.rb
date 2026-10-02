# frozen_string_literal: true

class AccountDeletionMailer < ApplicationMailer
  def confirmation(user, token)
    @user = user
    @deletion_url = account_deletion_confirm_url(token: token)

    mail(
      to: user.email,
      subject: t("account_deletion.mailer.subject")
    )
  end
end
