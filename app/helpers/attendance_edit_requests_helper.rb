module AttendanceEditRequestsHelper

  # 勤怠編集申請を返す（attendance.idから探す）
  def attendance_edit_request(day)
    AttendanceEditRequest.find_by(attendance_id: day.id)
  end
  
end
