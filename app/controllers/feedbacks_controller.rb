class FeedbacksController < ApplicationController
  before_action :authenticate_user!

  def create
    @feedback = current_user.feedbacks.build(feedback_params)

    if @feedback.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("feedback-modal-container",
            "<div id='feedback-modal-container'
                  data-controller='feedback-modal'
                  style='display:flex; position:fixed; inset:0; z-index:50; background:rgba(0,0,0,0.45); align-items:flex-end; justify-content:center; padding:0;'>
              <div style='background:#FAF7F4; border-radius:24px 24px 0 0; padding:32px 24px 40px; width:100%; max-width:430px; position:relative; text-align:center;'>
                <div style='width:40px; height:4px; background:#D1C4C2; border-radius:2px; margin:0 auto 24px;'></div>
                <div style='width:56px; height:56px; background:#f0faf4; border-radius:50%; display:flex; align-items:center; justify-content:center; margin:0 auto 16px;'>
                  <svg width='28' height='28' fill='none' stroke='#2E6B3E' stroke-width='2.5' viewBox='0 0 24 24'>
                    <polyline points='20 6 9 17 4 12'/>
                  </svg>
                </div>
                <p style='color:#933a35; font-size:18px; font-weight:600; font-family:Montserrat,sans-serif; margin:0 0 8px;'>Thank you!</p>
                <p style='color:#6B6B6B; font-size:14px; font-family:Montserrat,sans-serif; margin:0 0 24px;'>Your message has been received.</p>
                <button type='button'
                        data-action='click->feedback-modal#close'
                        style='background:#933a35; color:#fff; border:none; border-radius:12px; padding:12px 32px; font-size:15px; font-weight:600; font-family:Montserrat,sans-serif; cursor:pointer;'>
                  Close
                </button>
              </div>
            </div>")
        end
        format.html { redirect_to user_root_path, notice: t(".thank_you") }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("fm-error",
            "<p id='fm-error' style='color:#933a35; font-size:13px; margin:8px 0 0;'>#{t(".enter_message")}</p>")
        end
        format.html { redirect_to user_root_path, alert: t(".enter_message") }
      end
    end
  end

  private

  def feedback_params
    params.expect(feedback: [:type, :message, :media])
  end
end
