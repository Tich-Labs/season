# frozen_string_literal: true

class AccountDeletionMailer < ApplicationMailer
  def confirmation(user, token)
    @user = user
    @deletion_url = account_deletion_confirm_url(token: token)

    I18n.with_locale(user.language.presence || I18n.default_locale) do
      mail(
        to: user.email,
        subject: t("account_deletion.mailer.subject")
      )
    end
  end
end
