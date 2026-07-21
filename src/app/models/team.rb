class Team < ApplicationRecord
  has_many :events, dependent: :destroy
  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members

  validates :name, presence: true

  before_create :assign_color

  TEAM_COLORS = [
    "#3B82F6", # Blue
    "#10B981", # Green
    "#EF4444", # Red
    "#F59E0B", # Amber
    "#8B5CF6", # Purple
    "#06B6D4", # Cyan
    "#EC4899", # Pink
    "#84CC16"  # Lime
  ].freeze

  private

  def assign_color
    self.color ||= TEAM_COLORS[Team.count % TEAM_COLORS.size]
  end
end
