class Team < ApplicationRecord
  belongs_to :owner, class_name: 'User'

  has_many :team_members
  has_many :users, through: :team_members
end
