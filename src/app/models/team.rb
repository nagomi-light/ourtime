class Team < ApplicationRecord
  validates :name, presence: true

  has_many :events, dependent: :destroy
  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members
end
