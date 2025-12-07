class User < ApplicationRecord
    has_secure_password
    
    has_many :team_members
    has_many :teams, through: :team_members
    has_many :owned_teams, class_name: 'Team', foreign_key: 'owner_id'
end
