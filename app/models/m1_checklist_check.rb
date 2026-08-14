class M1ChecklistCheck < ApplicationRecord
  belongs_to :user

  validates :item_key, presence: true, uniqueness: {scope: :user_id}
end
