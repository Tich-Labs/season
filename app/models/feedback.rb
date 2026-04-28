class Feedback < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :user
  has_one_attached :media

  enum :type, {feedback: "feedback", bug_report: "bug_report", support: "support"}, prefix: :feedback_type

  validates :message, presence: true
  validates :type, presence: true

  after_create_commit :forward_to_trello

  private

  def forward_to_trello
    TrelloMailer.card(self).deliver_later
  rescue => e
    Rails.logger.error "TrelloMailer enqueue failed for Feedback##{id}: #{e.message}"
  end
end
