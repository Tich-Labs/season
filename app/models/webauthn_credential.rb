class WebauthnCredential < ApplicationRecord
  # credential_id/public_key/sign_count are set once, at registration, from
  # the `webauthn` gem's verified WebAuthn::Credential — see
  # WebauthnController#register. sign_count is updated on every successful
  # #authenticate; a value that doesn't strictly increase means the
  # authenticator (or a clone of it) is being replayed, which the gem
  # rejects before this record is ever touched.
  belongs_to :user
  validates :credential_id, presence: true, uniqueness: true
  validates :public_key, presence: true
end
