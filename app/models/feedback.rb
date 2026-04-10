class Feedback < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :user

  enum :type, {feedback: "feedback", bug_report: "bug_report", support: "support"}, prefix: :feedback_type

  validates :message, presence: true
  validates :type, presence: true
end
