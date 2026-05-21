class NativeDevice < ApplicationRecord
  belongs_to :user, optional: true
  validates :device_token, presence: true, uniqueness: true
end
