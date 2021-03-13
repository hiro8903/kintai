class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :attending_index, :update, :destroy, :edit_basic_info, :update_basic_info, :show_one_week]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :show_one_week]
  before_action :correct_user, only: [:edit]
  before_action :admin_user, only: [:update, :destroy, :edit_basic_info, :update_basic_info, :index, :attending_index]
  before_action :admin_or_correct_user, only: [:edit]
  before_action :admin_or_correct_user_or_requesting_user, only:[:show]
  before_action :set_one_month, only: [:show, :show_one_week]
  # before_action :rs, only: [:show]
  before_action :set_one_week , only: :show_one_week
  
  def index
 
    #キーワードが入力されていれば、whereメソッドとLIKE検索（部分一致検索）を組み合わせて、必要な情報のみ取得する。
    if params[:user_search]
      @users = User.where('name LIKE ?', "%#{params[:user_search]}%").paginate(page: params[:page])
      @page_title ="検索結果"
    else
      @users = User.paginate(page: params[:page])
      @page_title ="ユーザー一覧"
    end
    
  end

  # 出勤中社員一覧ページを表示
  def attending_index
    today = Date.today
    @today_attendances = Attendance.where(worked_on: today, finished_at: nil).where.not(started_at: nil)
  end

  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
    # 上長表示関連
    @superiors = User.where(superior: true)
    @superiors_other_then_myself = @superiors.where.not(id: @user.id)
    # ひと月の勤怠申請関連
    @monthly_requests = MonthlyRequest.where(requested_id: @user.id, state:2)
    @monthly_request = MonthlyRequest.find_by(requester_id: @user.id,request_month: @first_day)
    # 残業申請関連
    @over_time_requests = OverTimeRequest.where(requested_id: @user.id, state:2)
    # 勤怠編集申請関連
    @attendance_edit_requests = AttendanceEditRequest.where(requested_id: @user.id, state: 2)
  end
  
  def show_one_week
    @worked_sum = @attendances_of_week.where.not(started_at: nil).count
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user # 保存成功後、ログインする。
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to users_url
    else
      if params[:user_search]
        @users = User.where('name LIKE ?', "%#{params[:user_search]}%").paginate(page: params[:page])
        @page_title ="検索結果"
      else
        @users = User.paginate(page: params[:page])
        @page_title ="ユーザー一覧"
      end
      render :index      
    end
    
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end

  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
      redirect_to @user and return
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url and return
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :basic_work_time, :work_time, :password,  :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:basic_work_time, :work_time)
    end
    
    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "権限がありません。"
        redirect_to(root_url)
      end  
    end

    # 管理権限者、または現在ログインしているユーザー、または申請先の上長を許可します。
    def admin_or_correct_user_or_requesting_user
      @user = User.find(params[:id]) if @user.blank?
      unless current_user?(@user) || current_user.admin? || @user.monthly_requesting.find_by(id:current_user) == current_user || @user.over_time_requesting.find_by(id:current_user) == current_user || @user.attendance_edit_requesting.find_by(id:current_user) == current_user
        flash[:danger] = "権限がありません。"
        redirect_to(root_url)
      end  
    end
end