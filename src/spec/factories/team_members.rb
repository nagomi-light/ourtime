FactoryBot.define do
  factory :team_member do
    association :team
    association :user
    role { "member" }
  end
end