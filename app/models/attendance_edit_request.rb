class AttendanceEditRequest < ApplicationRecord
  belongs_to :attendance
  belongs_to :requested, class_name: "User"
  belongs_to :requester, class_name: "User"
  validates :requester_id, presence: true
  validates :requested_id, presence: true
  validates :state, presence: true
  validates :started_at, presence: true
  validates :finished_at, presence: true
  # 出勤時間が存在しない場合、退勤時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  # 出勤・退勤時間どちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_than_finished_at_fast_if_invalid
  
end
