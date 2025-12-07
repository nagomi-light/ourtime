FactoryBot.define do
  factory :event do
    association :user
    association :team

    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    start_time { Faker::Time.forward(days: 1) }
    end_time { start_time + 2.hours }
    repeat_rule { nil } 
  end
end