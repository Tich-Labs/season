class ConfirmationsController < Devise::ConfirmationsController
  # Auth-flow page — render the minimal "launch" chrome, not the in-app
  # layout (which would bolt the calendar-home and quick-actions FABs onto
  # the "Resend confirmation" screen for a signed-in-but-unconfirmed user).
  layout "launch"

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      login(resource)
      redirect_to after_sign_in_path, notice: t("confirmations.success")
    else
      redirect_to new_user_confirmation_path,
        alert: t("confirmations.expired")
    end
  end
end
