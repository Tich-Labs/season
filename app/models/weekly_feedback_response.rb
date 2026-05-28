class WeeklyFeedbackResponse < ApplicationRecord
  belongs_to :user
  belongs_to :weekly_feedback_question

  validates :week_number, presence: true
  validates :submission_batch_id, presence: true
  validate :response_present

  scope :for_batch, ->(batch_id) { where(submission_batch_id: batch_id) }
  scope :for_week, ->(user, week) { where(user: user, week_number: week) }

  after_create_commit :forward_to_admin_inbox

  private

  def response_present
    if selected_option.blank? && response_text.blank?
      errors.add(:base, :blank, message: "must provide a response")
    end
  end

  def forward_to_admin_inbox
    WeeklyFeedbackMailer.summary(self).deliver_later
  rescue => e
    Rails.logger.error "WeeklyFeedbackMailer enqueue failed for Response##{id}: #{e.message}"
  end
end
