FactoryBot.define do
  factory :calendar_event do
    association :user
    title { "Dentist appointment" }
    date { Time.zone.tomorrow }
    start_time { "10:00" }
    end_time { "11:00" }
    category { "Medical" }
  end
end
