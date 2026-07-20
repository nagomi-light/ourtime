class Event < ApplicationRecord
  belongs_to :user
  belongs_to :team, optional: true

  validates :title, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true

  validate :end_time_after_start_time

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?

    errors.add(:end_time, "は開始日時より後にしてください") if end_time <= start_time
  end
end
