class SymptomLog < ApplicationRecord
  belongs_to :user
  validates :date, presence: true
  validates :date, uniqueness: {scope: :user_id}
  TRACKABLE = %w[mood energy sleep physical mental
    pain cravings discharge].freeze
end
