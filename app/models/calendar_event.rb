class CalendarEvent < ApplicationRecord
  belongs_to :user
  validates :title, :date, presence: true
  scope :for_date, ->(date) { where(date: date) }
  scope :ordered, -> { order(:start_time) }
end
