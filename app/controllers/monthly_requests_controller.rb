class MonthlyRequestsController < ApplicationController
  before_action :logged_in_user, only: [:update, :edit]
  # before_action :admin_or_correct_user, only: [:edit, :update ]
  before_action :set_user, only: [:update]
  # before_action :logged_in_user, only: [:update]
  # before_action :correct_user, only: [:update]
  before_action :set_one_month, only: :update

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

  private
    
    def monthly_request_params
      # params.require(:user).permit(:name, :email, :password, :affiliation, :password_confirmation)
      # params.require(:user).permit(monthly_requests: [:state, :requested])
      # params.permit(:state, :requested_id )
      params.require(:monthly_request).permit(:state, :requested_id)
    end

end
