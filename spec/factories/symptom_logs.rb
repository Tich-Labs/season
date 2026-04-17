FactoryBot.define do
  factory :symptom_log do
    association :user
    date { Time.zone.today }
    mood { 3 }
    energy { 3 }
    sleep { 3 }
    notes { nil }
  end
end
