class User < ApplicationRecord
    has_many :owned_teams, class_name: 'Team', foreign_key: 'owner_id'
end
