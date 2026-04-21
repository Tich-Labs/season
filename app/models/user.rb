class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :confirmable,
    :omniauthable, omniauth_providers: [:google_oauth2, :facebook, :apple]

  generates_token_for :password_reset, expires_in: 1.hour

  validates :name, presence: true, if: :onboarding_completed?

  has_one_attached :avatar
  has_many :cycle_entries, dependent: :destroy
  has_many :calendar_events, dependent: :destroy
  has_many :symptom_logs, dependent: :destroy
  has_many :superpower_logs, dependent: :destroy
  has_many :reminders, dependent: :destroy
  has_many :feedbacks, dependent: :destroy
  has_one :streak, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    %w[email name created_at onboarding_completed language]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  # Required fields per onboarding step. Steps with a "skip" option (4, 10, 11)
  # are intentionally omitted — users may legitimately leave those nil.
  REQUIRED_ONBOARDING_STEPS = {
    1 => ->(u) { u.name.present? },
    2 => ->(u) { u.birthday.present? },
    3 => ->(u) { !u.has_regular_cycle.nil? },
    5 => ->(u) { !u.uses_hormonal_birth_control.nil? },
    9 => ->(u) { u.food_preference.present? }
  }.freeze

  # Returns the first step number where required data is missing, or nil when
  # all required fields are present. Used to resume or nudge profile completion.
  def first_incomplete_onboarding_step
    return 1 unless onboarding_completed?

    REQUIRED_ONBOARDING_STEPS.find { |_step, check| !check.call(self) }&.first
  end

  def profile_complete?
    first_incomplete_onboarding_step.nil?
  end

  def onboarding_completed?
    onboarding_completed == true
  end

  def current_phase
    return nil unless last_period_start
    CycleCalculatorService.new(self).current_phase
  end

  def current_cycle_day
    return nil unless last_period_start
    (Time.zone.today - last_period_start.to_date).to_i + 1
  end

  def first_name
    name&.split&.first || name
  end

  def self.find_or_create_from_oauth(provider, auth)
    find_or_initialize_by(email: auth.info.email.downcase).tap do |user|
      user.assign_attributes(
        :name => auth.info.name,
        "#{provider}_uid" => auth.uid
      )
      user.save! if user.new_record?
    end
  rescue ActiveRecord::RecordInvalid
    user
  end
end
