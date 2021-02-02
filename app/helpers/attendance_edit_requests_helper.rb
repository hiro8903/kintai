module AttendanceEditRequestsHelper

  # 出勤時間または退勤時間だけになる編集は無効 コピーしただけ。これから中身を編集する。
  def edit_update_only_one_side?
    true
  debugger
  end

  def attendance_edit_request(day)
    AttendanceEditRequest.find_by(attendance_id: day.id)
  end

  
end
