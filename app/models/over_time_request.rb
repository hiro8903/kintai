class OverTimeRequest < ApplicationRecord
  belongs_to :attendance
  belongs_to :requested, class_name: "User"
  belongs_to :requester, class_name: "User"
  with_options presence: true do
    validates :attendance_id
    validates :requester_id
    validates :requested_id
    validates :end_scheduled_at
  end
  validates :content,length: { maximum: 50 }
  # validate :designated_work_end_time_than_end_scheduled_at_fast_if_invalid

  def designated_work_end_time_than_end_scheduled_at_fast_if_invalid
    if end_scheduled_at.present? 
      errors.add(:designated_work_end_time, "より早い残業時間は無効です") if requester.designated_work_end_time.change(year: attendance.worked_on.year, month: attendance.worked_on.month, day: attendance.worked_on.day) >= end_scheduled_at
    end
  end

end
