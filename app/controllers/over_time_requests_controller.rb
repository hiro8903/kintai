class OverTimeRequestsController < ApplicationController

  # 残業申請を行うページを表示。
  def new
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:format])
    @over_time_request = OverTimeRequest.find_by(attendance_id: @attendance.id).nil? ?
    @attendance.build_over_time_request(requester_id: @attendance.user_id) : OverTimeRequest.find_by(attendance_id: @attendance.id)
    @superiors = User.where(superior: true)
    @superiors_other_then_myself = @superiors.where.not(id: @user.id)
  end

  # 上長へ残業申請を行う。
  def create
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:attendance_id])
    @over_time_request = @attendance.build_over_time_request(over_time_request_params)
    @over_time_request[:requester_id] = @attendance.user_id
    @over_time_request[:state] = "申請中"
     scheduled_end_time(@over_time_request,@attendance)
    if @over_time_request.save
      flash[:success] = "#{User.find(@over_time_request.requested_id).name}に残業申請しました。"
      redirect_to user_url(@user, date: @over_time_request.end_scheduled_at.beginning_of_month)
    else
      flash[:danger] ="#{@over_time_request.errors.full_messages.join}"
      redirect_to user_url(@user, date: @over_time_request.attendance.worked_on.beginning_of_month)
    end
  end

  # 自分に対しての残業申請一覧ページを表示する。このページで申請された状態を確認し、それぞれに対して承認・否認等を選択。
  def edit
    @user = User.find(params[:user_id])
    @all_requests = OverTimeRequest.where(requested: @user, state: "申請中").order(attendance_id: :asc)
    @requesters = User.find(@all_requests.pluck(:requester_id).uniq)
  end

  # チェックの入った残業申請のみ、申請状態を変更する（ 申請中から承認・否認等 )。
  def update
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      over_time_requests_params.each do |id, item|
        request = OverTimeRequest.find(id)
        if params[:over_time_requests][id][:check] == "1" # チェックボックスにチェックが入っているところのみ更新する。
          request.update_attributes!(item) 
          request.delete if request[:state] == "なし" # 「なし」を選択したものは申請を削除する。
        end
      end
    end
      flash[:success] = "残業申請を更新しました。"
      redirect_to user_url(current_user)
    rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
      flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
      if request.errors.any?
        request.errors.full_messages.each do |msg| 
          flash[:danger] = "#{msg}"
        end 
      end
      redirect_to user_url(current_user)
  end

  private

    # 残業申請時のparams( def create )
    def over_time_request_params
      params.require(:over_time_request).permit(:end_scheduled_at, :requested_id, :content, :state)
    end

    # 残業申請状態（申請中）を更新時のparams( def update )
    def  over_time_requests_params
      params.permit(over_time_requests: [:state])[:over_time_requests]
    end

    # 終了予定時間を返す（指定勤務終了時間を申請日の年月日に合わせ、翌日チェックボックスのチェックの有無で終了予定時間の日付を当日にするか翌日にするか判断する）
    def scheduled_end_time(over_time_request,attendance)
      if over_time_request.end_scheduled_at.present? # 終了予定時間が入力されているときだけ実行する。
        if params[:over_time_request][:tomorrow] == "0" # 翌日チェックボックスにチェックが "無い" 場合は所定外勤務時間の終了予定時間を計算を当日とする
          over_time_request[:end_scheduled_at]= over_time_request.end_scheduled_at.change(year: attendance.worked_on.year, month: attendance.worked_on.month, day: (attendance.worked_on.day) )
        else # 翌日チェックボックスにチェックが "ある" 場合は所定外勤務時間の終了予定時間を翌日とする
          over_time_request[:end_scheduled_at]= over_time_request.end_scheduled_at.change(year: attendance.worked_on.year, month: attendance.worked_on.month, day: (attendance.worked_on.day + 1) )
        end
      end
    end
end