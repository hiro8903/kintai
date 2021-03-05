class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  enum state: { "なし": 1, "申請中": 2, "承認": 3, "否認": 4 }

  # 出社時間が未入力で退勤時間が入力されている場合は無効にする。
  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end
  
  # 退勤時間が出社時間よりも早い場合は無効にする。
  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
    end
  end
end
