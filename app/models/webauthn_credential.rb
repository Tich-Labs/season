class WebauthnCredential < ApplicationRecord
  belongs_to :user
  validates :credential_id, presence: true, uniqueness: true
  validates :public_key, presence: true
end
