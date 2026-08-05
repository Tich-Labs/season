class Reminder < ApplicationRecord
  belongs_to :user
  TYPES = %w[supplement pill period_start
    period_end morning evening in_app].freeze
  validates :reminder_type, inclusion: {in: TYPES}
  scope :active, -> { where(active: true) }
end
