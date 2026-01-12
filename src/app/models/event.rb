class Event < ApplicationRecord
  belongs_to :user
  belongs_to :team, optional: true

  # validates :title, presence: true
end
