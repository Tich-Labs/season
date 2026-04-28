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
            partial: "feedbacks/error", locals: {message: t("feedback.create.enter_message")})
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
