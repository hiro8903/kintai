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

  # CSVファイルをインポートしユーザーを登録する
  def import
    # 現在登録済みのユーザー数
    current_users_count = User.count
    if params[:file].blank? # ファイルが選択されていない場合
      flash[:danger] = "ファイルを選択してください。"
      redirect_to users_url
    else # CSVファイルが選択されている場合
      # CSVファイルを読み込む
      User.import(params[:file])
      # CSVファイル内のユーザー数をcountに代入
      count = 0
      CSV.foreach(params[:file].path, headers: true) do |row|
        count += 1
      end
      # 登録完了後のユーザー数
      after_users_count = User.count
      # 登録に成功したユーザー数
      success_users_count = after_users_count - current_users_count
      # 登録に失敗したユーザー数
      error_users_count = count - success_users_count
      flash[:success] = "#{success_users_count}件のインポートに成功しました。" if success_users_count > 0
      flash[:danger] = "#{error_users_count}件のインポートに失敗しました。" if error_users_count > 0
      redirect_to users_url
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
    # 現在のユーザーに対して勤怠編集申請中のもの
    @attendance_edit_requests = AttendanceEditRequest.where(requested_id: @user.id, state: 2)
    # respond_to はリクエストに応じた処理を行うメソッドです。
    # 通常時はhtmlをリクエストしているので、処理は記述していません。
    # viewのlink_toでformatをcsvとして指定しているので、
    # リンクを押すとsend_attendances_csv(@attendances)の処理を行います。
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_attendances_csv(@attendances)
      end
    end
  end
  
  def show_one_week
    @worked_sum = @attendances_of_week.where.not(started_at: nil).count
  end

  def new
    users = User.all
    # debugger
    max_employee_number = users.select("employee_number").order("employee_number desc").last.employee_number
    # 社員番号の初期値に「すでに使用されている最大番号＋１」を入れておく。
    @user = User.new(employee_number: max_employee_number + 1)
  end

  def create
    debugger
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

    def send_attendances_csv(attendances)
      # CSV.generateとは、対象データを自動的にCSV形式に変換してくれるCSVライブラリの一種
      csv_data = CSV.generate do |csv|
        # %w()は、空白で区切って配列を返します
        # debugger
        column_names = %w(日時 出社時間 退社時間)
        # csv << column_namesは表の列に入る名前を定義します。
        csv << column_names
        # column_valuesに代入するカラム値を定義します。
        attendances.each do |attendance|
          # 勤怠編集申請が承認されていた場合は、CSVファイルに反映させる。
          if attendance.attendance_edit_request.present? && attendance.attendance_edit_request.state == "承認"
            column_values = [ attendance.worked_on,
                              attendance.attendance_edit_request.started_at,
                              attendance.attendance_edit_request.finished_at,
                            ]
          else # 勤怠編集申請が無い、または勤怠編集申請が承認されていない場合は、初期値をCSVファイルに反映させる。
            column_values = [ attendance.worked_on,
                              attendance.started_at,
                              attendance.finished_at,
                            ]
          end
          # csv << column_valueshは表の行に入る値を定義します。
          csv << column_values
        end
      end
      # csv出力のファイル名を定義します。
      send_data(csv_data, filename: "#{@user.name}-#{@first_day.year}年#{@first_day.month}月の勤怠情報.csv")
    end
end