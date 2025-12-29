class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
    has_secure_password
    
    has_many :team_members
    has_many :teams, through: :team_members
    has_many :owned_teams, class_name: 'Team', foreign_key: 'owner_id'
end
