class MonthlyRequestsController < ApplicationController
  before_action :logged_in_user, only: [:update, :edit, :request_update]
  # before_action :admin_or_correct_user, only: [:edit, :update ]
  before_action :set_user, only: [:update, :edit]
  # before_action :logged_in_user, only: [:update]
  # before_action :correct_user, only: [:update]
  before_action :set_one_month, only: [:update,]

  # 一月分の勤怠を申請する
  # def update

  #   if attendances_update_only_one_side?
  #     ActiveRecord::Base.transaction do # トランザクションを開始します。
  #       attendances_params.each do |id, item|
  #         @attendance = Attendance.find(id)
  #         @attendance.update_attributes!(item)
  #       end
  #       flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
  #       redirect_to user_url(date: params[:date])
  #     end
  #   end
  # rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
  #     flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
  #       if @attendance.errors.any?
  #         @attendance.errors.full_messages.each do |msg| 
  #         flash[:danger] = "#{msg}"
  #         end 
  #       end
  #     redirect_to attendances_edit_user_url(date: params[:date])
  # end  

  def update
    @monthly_request = MonthlyRequest.find_by(requester: @user, request_month: @first_day)
    # debugger
    if @monthly_request.update_attributes(monthly_request_params)
      
      @monthly_request.update_attributes(state: "申請中")
      # debugger
      flash[:success] = "#{@monthly_request.requested.name}に#{@monthly_request.request_month}の申請をしました。"
      redirect_to @user
    else
      render_to @user
    end
    # debugger
  end


  # def update
  #   if @user.update_attributes(user_params)
  #     flash[:success] = "ユーザー情報を更新しました。"
  #     redirect_to @user
  #   else
  #     render :edit      
  #   end
  # end

  def edit # 自分に申請されている一月分の勤怠申請をユーザー毎に表示する。（モーダルを表示させる）
    # debugger
    @all_requests = MonthlyRequest.where(requested: @user, state: "申請中")
    # @requesters = @user.monthly_requesters
    @requesters = User.find(@all_requests.pluck(:requester_id).uniq)
    # @requests = MonthlyRequest.where(requester_id: @requesters.pluck(:id))
    # debugger
  end

  # def request_update
  # # debugger

  #   redirect_to current_user
  #       ActiveRecord::Base.transaction do # トランザクションを開始します。
  #         requests_params.each do |id, item|
  #           request = MonthlyRequest.find(id)
  #           request.update_attributes!(item)
  #         end
  #       end
  #         flash[:success] = "1ヶ月分の勤怠情報を承認しました。"
  #         redirect_to user_url(date: params[:date])
  #   rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
  #       flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
  #         if @attendance.errors.any?
  #           @attendance.errors.full_messages.each do |msg| 
  #           flash[:danger] = "#{msg}"
  #           end 
  #         end
  #       redirect_to user_url(date: params[:date])

  # end
  def request_update

  # debugger
        ActiveRecord::Base.transaction do # トランザクションを開始します。
          requests_params.each do |id, item|
            request = MonthlyRequest.find(id)
            request.update_attributes!(item)
          end
        end
          flash[:success] = "1ヶ月分の勤怠情報を承認しました。"
          redirect_to user_url(current_user)
    rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
        flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
          if @attendance.errors.any?
            @attendance.errors.full_messages.each do |msg| 
            flash[:danger] = "#{msg}"
            end 
          end
          redirect_to user_url(current_user)


          # redirect_to user_url(current_user)
  
    end
    
  private
    
    def monthly_request_params
      # params.require(:user).permit(:name, :email, :password, :affiliation, :password_confirmation)
      # params.require(:user).permit(monthly_requests: [:state, :requested])
      # params.permit(:state, :requested_id )
      params.require(:monthly_request).permit(:requested_id)
    end

    def requests_params
      # params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
      # params.require(:monthly_request).permit(:state)[:monthly_requests]
      params.permit(monthly_requests: [:state])[:monthly_requests]
    end

end
