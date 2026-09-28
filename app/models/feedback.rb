class Feedback < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :user
  belongs_to :archived_by, class_name: "User", optional: true
  has_one_attached :media

  enum :type, {feedback: "feedback", bug_report: "bug_report", support: "support"}, prefix: :feedback_type

  validates :message, presence: true
  validates :type, presence: true

  scope :active, -> { where(active: true) }
  scope :archived, -> { where(active: false) }

  def archived?
    !active?
  end

  def archive!(by:)
    update!(active: false, archived_at: Time.current, archived_by: by)
  end

  def unarchive!
    update!(active: true, archived_at: nil, archived_by: nil)
  end

  def support_or_bug?
    feedback_type_support? || feedback_type_bug_report?
  end

  after_create_commit :forward_to_trello

  private

  def forward_to_trello
    TrelloMailer.card(self).deliver_later
  rescue => e
    Rails.logger.error "TrelloMailer enqueue failed for Feedback##{id}: #{e.message}"
  end
end
