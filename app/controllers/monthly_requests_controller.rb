class MonthlyRequestsController < ApplicationController
  before_action :logged_in_user, only: [:update, :edit, :request_update, :request_confirmation]
  before_action :set_user, only: [:update, :edit, :request_confirmation]
  before_action :set_one_month, only: [:update, :edit]

  def update # ひと月分の勤怠を申請する
    @monthly_request = MonthlyRequest.find_by(requester: @user, request_month: @first_day)
    if @monthly_request.update_attributes(monthly_request_params)
      @monthly_request.update_attributes(state: "申請中")
      flash[:success] = "#{@monthly_request.requested.name}に#{@monthly_request.request_month}の申請をしました。"
      debugger
      redirect_to user_url(@user, date: @monthly_request.request_month)
    else
      render_to @user
    end
  end

  def edit # 自分(上長用)に申請されている一月分の勤怠申請をユーザー毎に表示する。（モーダルを表示させる）
    @all_requests = MonthlyRequest.where(requested: @user, state: "申請中")
    @requesters = User.find(@all_requests.pluck(:requester_id).uniq)
  end

  def request_update # 申請に対して状態を申請中から承認・非承認等にする。
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      requests_params.each do |id, item|
      request = MonthlyRequest.find(id)
        if item[:check] == "1" # チェックボックスにチェックが入っているところのみ更新する。
          request.update_attributes!(item) 
        end
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
    end
    
  private
    
    def monthly_request_params
      params.require(:monthly_request).permit(:requested_id)
    end

    def requests_params
      params.permit(monthly_requests: [:state, :check])[:monthly_requests]
    end

end
