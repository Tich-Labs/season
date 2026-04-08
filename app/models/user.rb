class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :omniauthable, omniauth_providers: [:google_oauth2, :facebook, :apple]

  validates :name, presence: true, if: :onboarding_completed?

  has_many :cycle_entries, dependent: :destroy
  has_many :calendar_events, dependent: :destroy
  has_many :symptom_logs, dependent: :destroy
  has_many :superpower_logs, dependent: :destroy
  has_many :reminders, dependent: :destroy
  has_one :streak, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    %w[email name created_at onboarding_completed language]
  end

  def self.ransackable_associations(auth_object = nil)
    []
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
    (Date.today - last_period_start.to_date).to_i + 1
  end

  def first_name
    name&.split&.first || name
  end

  def self.from_omniauth(provider, auth)
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
