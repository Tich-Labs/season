class ConfirmationsController < Devise::ConfirmationsController
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
