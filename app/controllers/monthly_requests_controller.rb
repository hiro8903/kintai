class MonthlyRequestsController < ApplicationController
  before_action :logged_in_user

  def create

      @monthly_request = MonthlyRequests.new(monthly_request_params)
      if @user.save
        log_in @user # 保存成功後、ログインする。
        flash[:success] = '新規作成に成功しました。'
        redirect_to @user
      else
        render :new
      end
  end


  private
    
    def monthly_request_params
      # params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
      params.require(:user).permit(monthly_requests: [:requet_month, :state, :requested_id])[:monthly_requests]
    end

end
