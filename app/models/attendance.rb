class Attendance < ApplicationRecord
  belongs_to :user
  has_one :over_time_request, dependent: :destroy
  # has_one :over_time_request
  # has_many :user, through: :over_time_requests
  # has_one :active_over_time_request, class_name:  "OverTimeRequest",
  #                                 foreign_key: "attendance_id",
  #                                 dependent:   :destroy
  # has_one :over_time_requesting, through: :active_over_time_requests, source: :requested
                                
  # has_one :passive_active_over_time_requests, class_name: "OverTimeRequest",
  #                                 foreign_key: "requested_id",
  #                                 dependent:   :destroy
  # has_one :over_time_requesters, through: :passive_over_time_requests, source: :requester
  
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  
  # 出勤時間が存在しない場合、退勤時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  # 出勤・退勤時間どちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_than_finished_at_fast_if_invalid
  
  # validate :cannot_update_only_one_side

  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end
  
  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
    end
  end

end
