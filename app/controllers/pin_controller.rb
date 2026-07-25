class PinController < ApplicationController
  RATE_LIMIT_STORE = ActiveSupport::Cache::MemoryStore.new

  allow_unauthenticated_access only: [:show, :verify]
  skip_onboarding_requirement
  allow_pin_bypass

  rate_limit to: 5, within: 15.minutes, only: :verify, with: -> { rate_limited }, store: RATE_LIMIT_STORE

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
      respond_to do |format|
        format.json { render json: {success: true} }
        format.html { redirect_to session.delete(:return_to_after_unlock) || user_root_path }
      end
    else
      respond_to do |format|
        format.json { render json: {error: t("pin.incorrect", default: "Incorrect code")}, status: :unprocessable_content }
        format.html do
          flash.now[:alert] = t("pin.incorrect", default: "Incorrect code")
          render :show, status: :unprocessable_content
        end
      end
    end
  end

  private

  def rate_limited
    if request.format.json?
      render json: {error: t("pin.too_many_attempts", default: "Too many attempts. Please try again later.")}, status: :too_many_requests
    else
      flash.now[:alert] = t("pin.too_many_attempts", default: "Too many attempts. Please try again later.")
      render :show, status: :too_many_requests
    end
  end
end
