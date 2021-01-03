class OverTimeRequestsController < ApplicationController
  # before_action :set_user, only: [:new]
  # before_action :logged_in_user, only: [:update, :edit]
  # before_action :admin_or_correct_user, only: [:edit, :update ]
  # before_action :set_one_month, only: :new

  def new
    
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:format])
    # debugger
    @over_time_request = @attendance.build_over_time_request(requester_id: @attendance.user_id)
    @superiors = User.where(superior: true)
    @superiors_other_then_myself = @superiors.where.not(id: @user.id)
    debugger
  end

  # def new
  #   @user = User.find(params[:user_id])
  #   @attendance = Attendance.find(params[:format])
  #   @over_time_request = @user.active_over_time_requests.new(attendance_id: @attendance.id)
  #   @superiors = User.where(superior: true)
  #   @superiors_other_then_myself = @superiors.where.not(id: @user.id)
  #   debugger
  # end

  def create
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:attendance_id])
    @over_time_request = @attendance.build_over_time_request(over_time_request_params)
    @over_time_request[:requester_id] = @attendance.user_id
    if params[:over_time_request][:tomorrow] == "0"
      @over_time_request[:end_scheduled_at]= @over_time_request.end_scheduled_at.change(year: @attendance.worked_on.year, month: @attendance.worked_on.month, day: (@attendance.worked_on.day) )
    else
      @over_time_request[:end_scheduled_at]= @over_time_request.end_scheduled_at.change(year: @attendance.worked_on.year, month: @attendance.worked_on.month, day: (@attendance.worked_on.day + 1) )
    end
    # @over_time_request[:state] = "申請中"
    # @over_time_request = @attendance.active_over_time_requests.new(over_time_request_params)
    debugger
    if @over_time_request.save
      flash[:success] = "#{User.find(@over_time_request.requested_id).name}に残業申請しました。"
      redirect_to @user
    else
      redirect_to @user
    end
    
  end
end

  private
    def over_time_request_params
      
      params.require(:over_time_request).permit(:end_scheduled_at, :requested_id)
    end