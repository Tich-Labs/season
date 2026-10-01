# frozen_string_literal: true

# The three screens of the public beta funnel are driven by plain form params,
# not a model. This form object validates them together and exposes the nested
# `beta_tester[...]` keys the view and controller share.
class BetaOnboarding::RegistrationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  PLATFORMS = BetaTester::PLATFORMS
  TERM = "terms_accepted"
  AGE = "age_confirmed"

  attribute :name, :string
  attribute :email, :string
  attribute :platform, :string
  attribute :terms_accepted, :string
  attribute :age_confirmed, :string

  validates :name, presence: true
  validates :email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :platform, presence: true, inclusion: {in: PLATFORMS}, allow_blank: true

  # The UI offers "Apple iOS" / "Android" / "Web" while the column stores
  # "ios" / "android" / "web", so normalise before validating rather than
  # rejecting a correct choice over casing.
  def platform=(value)
    super(value.to_s.downcase.presence)
  end
  validate :consents_accepted

  def to_beta_tester_attributes
    {name: name, email: email, platform: platform.to_s.downcase}
  end

  def terms_accepted? = terms_accepted.to_s == "1"

  # The registration screen offers a single combined checkbox ("I am at least
  # 18 years old and accept the Terms"), so ticking it grants both consents.
  # Only fall back to the terms value when `age_confirmed` was not sent
  # separately, so an explicit refusal is still respected.
  def age_confirmed?
    return age_confirmed.to_s == "1" if age_confirmed.present?

    terms_accepted?
  end

  # Params as they arrive nested under `beta_tester`, for the view.
  def self.param_keys = %i[name email platform terms_accepted age_confirmed]

  private

  def consents_accepted
    errors.add(:base, :terms) unless terms_accepted?
    errors.add(:base, :age) unless age_confirmed?
  end
end
