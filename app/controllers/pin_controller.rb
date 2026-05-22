class PinController < ApplicationController
  allow_unauthenticated_access only: [:show, :verify]
  skip_onboarding_requirement

  def show
    if authenticated? && current_user.pin_set?
      render :show
    else
      redirect_to root_path
    end
  end

  def verify
    if authenticated? && current_user.verify_pin(params[:pin])
      session[:pin_verified_at] = Time.current.to_i
      redirect_to session.delete(:return_to_after_unlock) || user_root_path
    else
      flash.now[:alert] = t("pin.incorrect", default: "Incorrect code")
      render :show, status: :unprocessable_content
    end
  end
end
