class FeedbacksController < ApplicationController
  before_action :authenticate_user

  def create
    @feedback = current_user.feedbacks.build(feedback_params)

    if @feedback.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("feedback-modal-container",
            partial: "feedbacks/success")
        end
        format.html { redirect_to user_root_path, notice: t("feedback.create.thank_you") }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("fm-error",
            "<p id='fm-error' style='color:#933a35; font-size:13px; margin:8px 0 0;'>#{t("feedback.create.enter_message")}</p>")
        end
        format.html { head :unprocessable_content }
      end
    end
  end

  private

  def feedback_params
    params.expect(feedback: [:type, :message, :media])
  end
end
