class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  $days_of_the_week = %w{日 月 火 水 木 金 土}

  
  # beforフィルター

  # paramsハッシュからユーザーを取得します。
  def set_user
    @user = User.find(params[:id])
  end

  def set_user_from_user_id
    @user = User.find(params[:user_id])
  end

  # ログイン済みのユーザーか確認します。
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください。"
      redirect_to login_url
    end
  end

  # アクセスしたユーザーが現在ログインしているユーザーか確認します。
  def correct_user
    redirect_to(root_url) unless current_user?(@user)
  end
  
  # システム管理権限所有かどうか判定します。
  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  # ページ出力前に1ヶ月分のデータの存在を確認・セットします。
  def set_one_month 
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date
=begin
三項演算子の他、
    @first_day = if params[:date].nil?
               Date.current.beginning_of_month
             else
               params[:date].to_date
             end
または
    if params[:date].nil?
      @first_day = Date.current.beginning_of_month
    else
      @first_day = params[:date].to_date
    end
どれも同じ結果を得られる
=end
    
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day] # 対象の月の日数を代入します。
    # ユーザーに紐付く一ヶ月分のレコードを検索し取得します。
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)

    unless one_month.count == @attendances.count # それぞれの件数（日数）が一致するか評価します。
        ActiveRecord::Base.transaction do # トランザクションを開始します。
          # 繰り返し処理により、1ヶ月分の勤怠データを生成します。
          one_month.each { |day| @user.attendances.create!(worked_on: day) }
        end
        @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
        # 一月分の申請を申請状態「なし」で作成する
        @monthly_request = MonthlyRequest.create!(requester_id: @user.id,requested_id: @user.id, request_month:@first_day, state:1)
    end
  
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
        flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
        redirect_to root_url
  end
  
  # ページ出力前に1週間分のデータの存在を確認・セットします。
  def set_one_week 
    @first_day_of_week = params[:date].nil? ?
    Date.current.beginning_of_week(:monday) : params[:date].to_date
    @last_day_of_week = @first_day_of_week.end_of_week(:monday)
    @attendances_of_week = @user.attendances.where(worked_on: @first_day_of_week..@last_day_of_week).order(:worked_on)
  end
  
end