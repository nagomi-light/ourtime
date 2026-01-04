FactoryBot.define do
    factory :user do
        name { "User #{Faker::Number.number(digits: 3)}" }
        email { Faker::Internet.email }
        password { "password" }
        password_confirmation { "password" }
    end
end
