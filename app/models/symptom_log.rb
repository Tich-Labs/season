class SymptomLog < ApplicationRecord
  belongs_to :user

  validates :date, presence: true, uniqueness: {scope: :user_id}

  TRACKABLE = %w[mood energy sleep physical mental
    pain cravings discharge].freeze

  SEVERITY_RANGE = 0..3

  PHYSICAL_SYMPTOMS = [
    {key: "headaches", label: "Headaches"},
    {key: "migraines", label: "Migraines"},
    {key: "dizziness", label: "Dizziness"},
    {key: "acne", label: "Acne"},
    {key: "neck_pain", label: "Neck pain"},
    {key: "shoulder_pain", label: "Shoulder pain"},
    {key: "back_pain", label: "Back pain"},
    {key: "breast_tenderness", label: "Breast tenderness"},
    {key: "breast_sensitivity", label: "Breast sensitivity"},
    {key: "lumbago", label: "Lumbago"},
    {key: "lower_back_pain", label: "Lower back pain"},
    {key: "joint_pain", label: "Joint pain"},
    {key: "abdominal_pain", label: "Abdominal pain"},
    {key: "flu", label: "Flu"},
    {key: "illness", label: "Illness"},
    {key: "cramps", label: "Cramps"},
    {key: "itching", label: "Itching"},
    {key: "rash", label: "Rash"},
    {key: "night_sweats", label: "Night sweats"},
    {key: "hot_flashes", label: "Hot flashes"},
    {key: "weight_gain", label: "Weight gain"},
    {key: "pms", label: "PMS"},
    {key: "pmdd", label: "PMDD"},
    {key: "pcos", label: "PCOS"}
  ].freeze

  MENTAL_SYMPTOMS = [
    {key: "anxiety", label: "Anxiety"},
    {key: "insomnia", label: "Insomnia"},
    {key: "moodiness", label: "Moodiness"},
    {key: "tension", label: "Tension"},
    {key: "irritability", label: "Irritability"},
    {key: "lack_of_concentration", label: "Lack of concentration"},
    {key: "fatigue", label: "Fatigue"},
    {key: "confusion", label: "Confusion"}
  ].freeze

  BLEEDING_FLOWS = ["Light", "Medium", "Heavy", "Disaster"].freeze

  def record_physical_symptom(key, value)
    record_symptom(:physical_symptoms, key, value)
  end

  def record_mental_symptom(key, value)
    record_symptom(:mental_symptoms, key, value)
  end

  def any_physical_symptom?
    physical_symptoms.values.any? { |v| v.to_i > 0 }
  end

  def any_mental_symptom?
    mental_symptoms.values.any? { |v| v.to_i > 0 }
  end

  def record_bleeding_flow(flow_name)
    return if flow_name.blank?
    return unless BLEEDING_FLOWS.include?(flow_name.to_s)

    update(bleeding: flow_name.to_s)
  end

  private

  def record_symptom(field, key, value)
    sanitized_key = key.to_s.gsub(/[^a-z_]/, "")
    return if sanitized_key.blank?

    severity = value.to_i.clamp(SEVERITY_RANGE.min, SEVERITY_RANGE.max)
    self[field] = (public_send(field) || {}).merge(sanitized_key => severity)
    save
  end
end
