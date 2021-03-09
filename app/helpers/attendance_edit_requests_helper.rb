module AttendanceEditRequestsHelper

  # 勤怠編集申請を返す（attendance.idから探す）
  def attendance_edit_request(day)
    AttendanceEditRequest.find_by(attendance_id: day.id)
  end
  
  # 編集ログの申請日付から紐付けられたAttendanceを返す。
  def attendance_day(edit_log)
    @edit_log_attendance = Attendance.find(edit_log.attendance_id)
  end

  # Attendanceの勤怠日月と与えられた年月が等しいか判別する。
  def match_of_year_and_month?(edit_log,yerar,month)
    attendance_day(edit_log)
    @edit_log_attendance.worked_on.year == year && @edit_log_attendance.worked_on.month == month
  end

  # 
  def repeat_times_count
    @i = @i +1
  end
end
