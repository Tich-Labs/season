class WeeklyFeedbackQuestion < ApplicationRecord
  QUESTION_TYPES = %w[multiple_choice yes_no_with_input text_only].freeze

  enum :question_type, {
    multiple_choice: "multiple_choice",
    yes_no_with_input: "yes_no_with_input",
    text_only: "text_only"
  }, prefix: :question_type

  validates :week_number, presence: true,
    numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 8}
  validates :question_type, presence: true, inclusion: {in: QUESTION_TYPES}
  validates :question_text, presence: true
  validates :position, presence: true, numericality: {only_integer: true}
  validate :options_present_for_multiple_choice

  has_many :responses, class_name: "WeeklyFeedbackResponse", dependent: :destroy

  scope :active, -> { where(active: true) }
  scope :for_week, ->(week) { active.where(week_number: week).order(:position) }

  private

  def options_present_for_multiple_choice
    if question_type_multiple_choice? && (options.blank? || !options.is_a?(Array) || options.size < 3)
      errors.add(:options, :too_short, message: "must have at least 3 options")
    end
  end
end
