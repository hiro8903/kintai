module AttendancesHelper
  
  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出社' if attendance.started_at.nil?
      return '退社' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    false
  end
  
  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
  end
  
  # 総合勤務時間（基本時間　×　出勤日数）
  def basic_times_sum(basic_time, worked_sum)
    format_basic_info(basic_time).to_f * worked_sum
  end
  
  # 出勤時間または退勤時間だけになる編集は無効
  def attendances_update_only_one_side?
    attendances = true
    attendances_params.each do |id, item|
      if item[:started_at].blank? && item[:finished_at].blank?
        next
      elsif item[:started_at].blank? || item[:finished_at].blank?
        attendances = false
        flash[:danger] = "出勤時間または退勤時間だけになる編集はできません。"
        redirect_to attendances_edit_user_url(date: params[:date])
      end
    end
    return attendances
  end

end
