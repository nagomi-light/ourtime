FactoryBot.define do
    factory :team do
        name { "Team #{Faker::Number.number(digits: 3)}" }
        
        association :owner, factory: :user
    end
end