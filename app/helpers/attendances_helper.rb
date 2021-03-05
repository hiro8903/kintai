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

  # working_time(no_edit, edit_time)の計算無いで使用する。出社時間と退社時間の差（在社時間）を計算します。
  def time_diff(start, finish)
      format("%.2f", (((finish.finished_at - start.started_at) / 60) / 60.0)) if start.started_at.present? && finish.finished_at.present?
  end

  # 勤怠変更申請をしている、または承認された場合の在社時間を計算する。勤怠表示画面で使用する。
  def working_time(no_edit, edit_time)
    # 勤怠の出勤と退勤が編集前・後が組み合わせでもいいので両方入力された状態である時。（出勤または退勤のどちらかしかの入力が無い、またはどちらも入力が無いという状態でないとき）
    if (no_edit.started_at.present? || (edit_time.present? && edit_time.started_at.present?)) && (no_edit.finished_at.present? || (edit_time.present? && edit_time.finished_at.present?))
      case 
      # 勤怠変更申請なしの場合、変更申請前の時刻で在社時間を計算する。
      when no_edit.present? && edit_time.nil?
        time_diff(no_edit, no_edit)
      # 勤怠変更申請が「申請中」の場合、変更申請の時刻で在社時間を計算する。
      when edit_time.present? && edit_time.state == "申請中" 
        time_diff(edit_time, edit_time)
        # 勤怠変更申請が「「承認」の場合、変更申請の時刻で在社時間を計算する。
      when edit_time.present? && edit_time.state == "承認" 
        time_diff(edit_time, edit_time)
        #  勤怠変更申請が「なし」の場合、変更申請前の時刻で在社時間を計算する。
      when edit_time.present? && edit_time.state == "なし" 
        time_diff(no_edit, no_edit)
      #  勤怠変更申請が「否認」の場合、変更申請前の時刻で在社時間を計算する。
      else edit_time.present? && edit_time.state == "否認"
        time_diff(no_edit, no_edit)
      end
    end
  end

  # 勤怠変更申請をした場合の在社時間を計算する（申請中・承認・否認状態時）。勤怠編集画面で使用する。
  def request_working_time(no_edit, edit_time)
    # 勤怠の出勤と退勤が編集前・後が組み合わせでもいいので両方入力された状態である時。（出勤または退勤のどちらかしかの入力が無い、またはどちらも入力が無いという状態でないとき）
    if (no_edit.started_at.present? || (edit_time.present? && edit_time.started_at.present?)) && (no_edit.finished_at.present? || (edit_time.present? && edit_time.finished_at.present?))
      case 
      # 勤怠変更申請なしの場合、変更申請前の時刻で在社時間を計算する。
      when no_edit.present? && edit_time.nil?
        time_diff(no_edit, no_edit)
      # 勤怠変更申請が「申請中」の場合、変更申請の時刻で在社時間を計算する。
      when edit_time.present? && edit_time.state == "申請中" 
        time_diff(edit_time, edit_time)
      # 勤怠変更申請が「「承認」の場合、変更申請の時刻で在社時間を計算する。
      when edit_time.present? && edit_time.state == "承認" 
        time_diff(edit_time, edit_time)
      #  勤怠変更申請が「なし」の場合、変更申請前の時刻で在社時間を計算する。
      when edit_time.present? && edit_time.state == "なし" 
        time_diff(no_edit, no_edit)
      #  勤怠変更申請が「否認」の場合、変更申請前の時刻で在社時間を計算する。
      else edit_time.present? && edit_time.state == "否認"
        time_diff(edit_time, edit_time)
      end
    end
  end

  # 基準値(15)で割って小数点以下は切り捨て（２dで整数二桁）、15をかける
  # 基準値（今回は15）で割って小数点以下は切り捨て、その数に15をかければ丸めた数を返すことができます。
  # 例えば32÷15は、2.13...なので、小数点以下を切り捨てると2。×15＝30を返すことができます。
  def every_15_minutes(time)
    format("%.2d", (((time.min)/15)*15))
  end
  
  # 総合勤務時間（基本時間　×　出勤日数）
  def basic_work_times_sum(basic_work_time, worked_sum)
    format_basic_info(basic_work_time).to_f * worked_sum
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
