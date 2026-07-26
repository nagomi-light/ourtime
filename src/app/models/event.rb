class Event < ApplicationRecord
  belongs_to :user
  belongs_to :team, optional: true

  validates :title, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time

  def calendar_color
    if team.present?
      team.color
    else
      "#3B82F6" # Blue
    end
  end

  
  def error_attribute_name(attribute)
    return self.class.human_attribute_name(attribute) unless all_day?

    case attribute
    when :start_time
      "開始日"
    when :end_time
      "終了日"
    else
      self.class.human_attribute_name(attribute)
    end
  end

  private
  
  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?
    return if end_time > start_time

    errors.add(:end_time, end_time_after_start_time_message)
  end

  def end_time_after_start_time_message
    if all_day?
      "は開始日より後にしてください"
    else
      "は開始時間より後にしてください"
    end
  end

end
