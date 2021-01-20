module OverTimeRequestsHelper
  
  # 時間外時間 ( Userの指定勤務終了時間 ー OverTimeRequestの終了予定時間 )
  def over_time(user, day)
    sprintf("%.2f",(over_time_request(day).end_scheduled_at - user.designated_work_end_time.change(year: day.worked_on.year, month: day.worked_on.month, day: day.worked_on.day)) / 60 / 60)
  end
  
  # リクエストされた時間外時間 ( OverTimeRequestの終了予定時間 ー OverTimeRequestを申請しているUserの指定勤務終了時間 )
  def request_over_time(request)
    sprintf("%.2f",(request.end_scheduled_at - request.requester.designated_work_end_time.change(year: request.attendance.worked_on.year, month: request.attendance.worked_on.month, day: request.attendance.worked_on.day) )/60/60)
  end

  def over_time_tody(over_time_request, attendance)
    over_time_request[:end_scheduled_at]= over_time_request.end_scheduled_at.change(year: attendance.worked_on.year, month: attendance.worked_on.month, day: attendance.worked_on.day)
  end

end
