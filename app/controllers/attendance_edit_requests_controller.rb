class AttendanceEditRequestsController < ApplicationController
  protect_from_forgery with: :exception
  # include SessionsHelper

  before_action :set_user_from_user_id, only: [:new, :create] 
  before_action :logged_in_user, only: [:new, :create]
  before_action :admin_or_correct_user, only: [:new, :create ]
  before_action :set_one_month, only: [:new, :create]


  def new
    @superiors = User.where(superior: true)
    @superiors_other_then_myself = @superiors.where.not(id: @user.id)

    # @attendances.each do |day|
    #   debugger
    #   @attendance_edit_requests = day.attendance_edit_requests.build(started_at: day.started_at)
    # end

    # @attendance_edit_request = @attendance.build_attendance_edit_request
    # @attendance_edit_requests = @attendances.build_attendance_edit_request
    # @attendance_edit_requests.each { |day| day.build_attendance_edit_request if day.attendance_edit_request.nil? }
  end

# 勤怠の編集リクエストを一括登録。
def create
  @superiors = User.where(superior: true)
  @superiors_other_then_myself = @superiors.where.not(id: @user.id)
  # debugger
  ActiveRecord::Base.transaction do # トランザクションを開始します。
    attendance_edit_requests_params.each do |id, item|
      if changes_present?(item)
        @attendance = Attendance.find(id)
        @attendance_edit_request = @attendance.build_attendance_edit_request(item)
        @attendance_edit_request[:requester_id] = @user.id
        @attendance_edit_request[:state] = "申請中"
        to_compensate(item)
        @attendance_edit_request.save!      
      end
    end
  end
    flash[:success] = "1ヶ月分の勤怠編集を申請しました。"

  
    redirect_to user_url(@user, date: params[:date])
    # debugger
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    if @attendance_edit_request.errors.any?
      @attendance_edit_request.errors.full_messages.each do |msg|
      flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。#{msg}"
      end 
    end
    redirect_to new_user_attendance_edit_request_url(@user,date: @first_day)
  
end

    # 申請先ユーザー（上長）の他に変更内容が入力されているか確認する。
def changes_present?(item)
  item[:requested_id].present? && (item[:started_at].present? || item[:finished_at].present? || item[:note].present?)
end

def to_compensate(item)
    item[:started_at] == @attendance[:started_at] if item[:started_at].blank? 
    item[:finished_at] == @attendance[:finished_at] if item[:finished_at].blank?
end


# 申請者が空白の場合は取り消ししたい

private

  def attendance_edit_requests_params
    # params.permit(:attendance_id, :started_at, :finished_at, :content, :state, :updated_at)
    # params.permit(attendance_edit_requests: [:attendance_id, :started_at, :finished_at, :content, :state, :updated_at])
    # params.permit(:attendance_id, :started_at, :finished_at, :content, :state, :updated_at)
    # params.permit(:attendance_id, :started_at, :finished_at, :content, :state, :updated_at)[:attendance_edit_requests]
    params.permit(attendance_edit_requests: [:attendance_id, :requested_id, :started_at, :finished_at, :note , :state, :updated_at])[:attendance_edit_requests]

  end

  # 管理権限者、または現在ログインしているユーザーを許可します。
  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    unless current_user?(@user) || current_user.admin?
      flash[:danger] = "権限がありません。"
      redirect_to(root_url)
    end  
  end



#   # 勤怠の変更申請を行う際に、リクエストとして新規作成または編集。
#   def create
# # debugger
#       ActiveRecord::Base.transaction do # トランザクションを開始します。
#           # debugger
#           # @user = @attendance.user
#         attendance_edit_requests_params.each do |id, item|
#           # debugger
#         @attendance = Attendance.find(id)
  
#           debugger
#           # @user = @attendance.user
#           # @attendance_edit_request = @user.attendance_edit_requests.new(attendance_id: id, requested_id: @user.id)
#           @attendance_edit_request = @attendance.build_attendance_edit_request(item)
# debugger
#           # @attendance_edit_request.update_attributes!(item)
#           @attendance_edit_request[:started_at] = @attendance_edit_request.started_at.change(year: @attendance.worked_on.year, month: @attendance.worked_on.month, day: @attendance.worked_on.day) if @attendance_edit_request[:started_at].present?
#           @attendance_edit_request[:finished_at] = @attendance_edit_request.finished_at.change(year: @attendance.worked_on.year, month: @attendance.worked_on.month, day: @attendance.worked_on.day) if @attendance_edit_request[:finished_at].present?
#           @attendance_edit_request.save
#           # debugger
  
#         end
#         flash[:success] = "勤怠情報変更を申請しました。"
#         # redirect_to root_url
#         # debugger
#         redirect_to @user
#       end

#   rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
#       flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
#         if @attendance_edit_request.errors.any?
#           @attendance_edit_request.errors.full_messages.each do |msg| 
#           flash[:danger] = "#{msg}"
#           end 
#         end
#       redirect_to attendances_edit_user_url(date: params[:date])
#   end  

  # private

  #   def attendance_edit_requests_params
  #     # params.permit(:started_at, :finished_at, :content, :state, :updated_at)
  #     # params.permit(attendance_edit_requests: [:started_at, :finished_at, :content, :state, :updated_at])
  #     # params.require(:attendance_edit_request).permit(:started_at, :finished_at, :content, :state, :updated_at)
  #     # params.permit(attendances: [:requested_id, :started_at, :finished_at, :note, :state])[:attendance_edit_requests]
  #     # params.permit([:attendance][:attendance_edit_requests])
  #     # params.require(:over_time_request).permit(:end_scheduled_at, :requested_id, :content, :state)
  #     params.require(:attendance_edit_request).permit(:started_at, :finished_at, :content, :state, :updated_at)
  #   end

end
