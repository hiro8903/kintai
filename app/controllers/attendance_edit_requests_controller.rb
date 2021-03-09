class AttendanceEditRequestsController < ApplicationController
  protect_from_forgery with: :exception

  before_action :set_user_from_user_id, only: [:new, :index, :create, :edit, :edited_table] 
  before_action :logged_in_user, only: [:new, :create]
  before_action :admin_or_correct_user, only: [:new, :create]
  before_action :set_one_month, only: [:new, :create, :edit]

  # 勤怠変種ページを表示
  def new
    @superiors = User.where(superior: true)
    @superiors_other_then_myself = @superiors.where.not(id: @user.id)
  end

  def index
    
    @attendance_edit_logs = @user.attendance_edit_requests.where(state: "承認")

    # debugger
  end

  # def edited_table
  #   debugger
  # end

  def edited_table
    # indexページにある「data(入力フォーム)」のパラメーターを@textに代入

    @text = params[:data]
    @year = params["date"]["year"]
    @month = params["date"]["month"]
    @attendance_edit_logs = @user.attendance_edit_requests.where(state: "承認")

    # debugger
  end

  # 勤怠の編集リクエストを一括登録。
  def create
    @superiors = User.where(superior: true)
    @superiors_other_then_myself = @superiors.where.not(id: @user.id)
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      attendance_edit_requests_params.each do |id, item|
        @attendance = Attendance.find(id)
        if changes_present?(item) # 申請先ユーザー（上長）の他に変更内容も入力されているか確認する。 
            # すでに申請されていて、状態が承認済みまたは否認の場合はそのままのインスタンスを保持する。（編集しても反映されない。ただし、上長の選択を外した場合は申請状態に限らず取り消し可能。）
          if @attendance.attendance_edit_request.present? && (@attendance.attendance_edit_request.state == "承認" || @attendance.attendance_edit_request.state == "否認")
            @attendance_edit_request = @attendance.attendance_edit_request
          else # 状態なしまたは申請中の場合、新規作成する。（申請中の場合は上書きされる。）
            @attendance_edit_request = @attendance.build_attendance_edit_request(item)
            @attendance_edit_request[:requester_id] = @user.id
            @attendance_edit_request[:state] = "申請中"
            scheduled_end_time(@attendance_edit_request,@attendance) # 翌日チェックボックスのチェックｎ有無で終了日時を当日か翌日か判断する。
            to_compensate(item) # 勤怠変更時に変更後の時刻の値が空白だった場合、変更前の出勤時間・退勤時間を入れる。
            @attendance_edit_request.save!
          end          
        else # 指示者確認（申請先）が空白の場合は申請を取り消す。
          @attendance_edit_request = @attendance.build_attendance_edit_request(item)
          if @attendance_edit_request.present?
            @attendance_edit_request.delete
          end
        end
      end
    end
      flash[:success] = "1ヶ月分の勤怠編集を申請しました。"
      # 勤怠変更申請した月の初日を取得
      day = @attendance.worked_on.beginning_of_month
      # 勤怠変更申請した月の勤怠編集編集画面に戻る
      redirect_to user_url(@user, date: day)
    rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
      if @attendance_edit_request.errors.any?
        @attendance_edit_request.errors.full_messages.each do |msg|
        flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。#{msg}"
        end 
      end
      # エラーが発生した月の初日を取得
      day = @attendance.worked_on.beginning_of_month
      # エラーが発生した月の勤怠編集編集画面に戻る
      redirect_to new_user_attendance_edit_request_url(@user,date: day)
  end

  # 自分に対しての勤怠変更申請一覧ページを表示する。このページで申請された状態を確認し、それぞれに対して承認・否認等を選択。
  def edit
    @user = User.find(params[:user_id])
    @all_requests = AttendanceEditRequest.where(requested: @user, state: "申請中")
    @requesters = User.find(@all_requests.pluck(:requester_id).uniq)

  end

  # チェックの入った残業申請のみ、申請状態を変更する（ 申請中から承認・否認等 )。
  def update
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      attendance_edit_requests_params.each do |id, item|
        request = AttendanceEditRequest.find(id)
        if params[:attendance_edit_requests][id][:check] == "1" # チェックボックスにチェックが入っているところのみ更新する。
          request.update_attributes!(item) 
        end
      end
    end
      flash[:success] = "勤怠変更申請を更新しました。"
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

    def attendance_edit_requests_params
      params.permit(attendance_edit_requests: [:attendance_id, :requested_id, :started_at, :finished_at, :note , :state, :updated_at])[:attendance_edit_requests]
    end

    # 申請先ユーザー（上長）の他に変更内容も入力されているか確認する。
    def changes_present?(item)
      item[:requested_id].present? && (item[:started_at].present? || item[:finished_at].present? || item[:note].present?)
    end

    # 勤怠変更時に変更後の時刻の値が空白だった場合、変更前の出勤時間・退勤時間を入れる。
    def to_compensate(item)
        item[:started_at] == @attendance[:started_at] if item[:started_at].blank? 
        item[:finished_at] == @attendance[:finished_at] if item[:finished_at].blank?
    end

    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "権限がありません。"
        redirect_to(root_url)
      end  
    end

    # 終了予定時間を返す（指定勤務終了時間を申請日の年月日に合わせ、翌日チェックボックスのチェックの有無で終了予定時間の日付を当日にするか翌日にするか判断する）
    def scheduled_end_time(request,attendance)
      # 申請する出勤日の年月日を勤怠の日時に調整する。
      request[:started_at] = request.started_at.change(year: attendance.worked_on.year, month: attendance.worked_on.month, day: attendance.worked_on.day) if request.started_at.present?
      if request.finished_at.present? # 終了予定時間が入力されている場合。
        if params[:attendance_edit_requests]["#{attendance.id}"][:tomorrow] == "0" # 翌日チェックボックスにチェックが "ない" 場合は所定外勤務時間の終了予定時間を当日とする
          request[:finished_at]= request.finished_at.change(year: attendance.worked_on.year, month: attendance.worked_on.month, day: attendance.worked_on.day)
        else # 翌日チェックボックスにチェックが "ある" 場合は所定外勤務時間の終了予定時間を翌日とする
          request[:finished_at]= request.finished_at.change(year: attendance.worked_on.year, month: attendance.worked_on.month, day: (attendance.worked_on.day + 1) )
        end
      end
    end

end
