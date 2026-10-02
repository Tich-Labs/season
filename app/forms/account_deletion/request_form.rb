# frozen_string_literal: true

# One-field form for the public account-deletion request page.
class AccountDeletion::RequestForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string

  validates :email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}

  def normalized_email
    email.to_s.strip.downcase.presence
  end
end
