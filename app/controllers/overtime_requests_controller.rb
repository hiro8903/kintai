class OvertimeRequestsController < ApplicationController

  before_action :logged_in_user, only: [:new, :create, :edit, :edit_user_overtime_request, :update]
  # before_action :correct_user, only: [:edit_user_overtime_request, :update]
  before_action :admin_user, only: [:new, :create, :edit, :edit_user_overtime_request]
  before_action :admin_or_correct_user, only: [:new, :create, :edit, :edit_user_overtime_request]
  before_action :set_one_month, only: [:new, :create, :edit, :edit_user_overtime_request]

  def show
    if @overtime_request.nil
      @user = User.find(params[:user_id])
      @overtime_request = OvertimeRequest.find(params[:id])
    end
  end


  def new
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:format])
    # debugger
    if @overtime_request.nil? # その日初の残業申請の場合
      @overtime_request = OvertimeRequest.new(attendance_id: params[:format], overtimed_on: Attendance.find(params[:format]).worked_on)
      
    else # 以前に残業申請をしたことがある場合
      @overtime_request = OvertimeRequest.find(params[:format])
    end
    # debugger
  end

  def create
    @user = User.find(params[:user_id])
    # debugger
    @overtime_request = OvertimeRequest.new(overtime_request_params)
    # debugger
    # @overtime_request = OvertimeRequest.new(attendance_id: params[:format], overtimed_on: @attendance.worked_on)
    # debugger
    if @overtime_request.save
      flash[:success] = '残業申請をしました。'
      redirect_to @user
    else
      flash[:danger] = '残業申請失敗しました。'
      redirect_to @user
     
    end
        
  end

  def edit
    @user = User.find(params[:user_id])
    @overtime_request = OvertimeRequest.find(params[:id])
    redirect_to root_url
  end

  # def update

  #   redirect_to root_url
  # end

  def update
    @user = User.find(params[:user_id])
    @overtime_request = OvertimeRequest.find(params[:id])
    if @overtime_request.update_attributes(overtime_request_params)
      flash[:success] = "残業申請しました。"
      redirect_to @user
    else
      flash[:denger] = "残業申請が失敗しました。"
      redirect_to root_url
    end
    
  end

  private

    def overtime_request_params
      params.require(:attendance).permit(overtime_requests: [:end_scheduled_at, :attendance_id, :overtimed_on])[:overtime_requests]
      # params.require(:attendance).permit(overtime_requests: [:end_scheduled_at, :attendance_id, :overtimed_on])[:overtime_requests]
      # params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end

      # 管理権限者、または現在ログインしているユーザーを許可します。
      def admin_or_correct_user
        @user = User.find(params[:user_id]) if @user.blank?
        unless current_user?(@user) || current_user.admin?
          flash[:danger] = "権限がありません。"
          redirect_to(root_url)
        end  
      end
end
