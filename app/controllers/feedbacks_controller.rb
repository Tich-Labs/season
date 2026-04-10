class FeedbacksController < ApplicationController
  before_action :authenticate_user!

  def create
    @feedback = current_user.feedbacks.build(feedback_params)

    if @feedback.save
      SupportMailer.support_request(@feedback).deliver_later if @feedback.feedback_type_support?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("feedback-modal",
            "<dialog id='feedback-modal' class='backdrop:bg-black/50 rounded-2xl p-0 w-[360px] max-w-[360px] mx-auto' data-controller='feedback-modal' data-action='click->feedback-modal#clickBackdrop'>
              <div class='bg-white rounded-2xl p-8 text-center'>
                <div class='w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4'>
                  <svg class='w-8 h-8 text-green-600' fill='none' stroke='currentColor' viewBox='0 0 24 24'>
                    <path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M5 13l4 4L19 7'></path>
                  </svg>
                </div>
                <p class='text-[#933a35] text-lg font-medium mb-2'>Thank you!</p>
                <p class='text-gray-500 text-sm'>Your feedback has been received.</p>
                <button type='button' data-action='click->feedback-modal#closeAndReload' class='mt-6 px-6 py-2 bg-[#933a35] text-white rounded-lg text-sm font-medium'>Close</button>
              </div>
            </dialog>")
        end
        format.html { redirect_to user_root_path, notice: t(".thank_you") }
      end
    else
      redirect_to user_root_path, alert: t(".enter_message")
    end
  end

  private

  def feedback_params
    params.expect(feedback: [:type, :message, :attachment])
  end
end
