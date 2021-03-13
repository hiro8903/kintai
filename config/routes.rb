Rails.application.routes.draw do
=begin
  「rails g コマンドで自動生成されたルーティング」
    get 'users/new'
    get 'static_pages/top' 
    get 'sessions/new'
=end

  root 'static_pages#top'  # トップページ表示
  get '/signup', to: 'users#new'  # ユーザー作成ページ表示

  # ログイン機能
  get    '/login', to: 'sessions#new' # ログインページ表示
  post   '/login', to: 'sessions#create'  # セッション作成（ログイン）
  delete '/logout', to: 'sessions#destroy'  # セッション削除（ログアウト）


  resources :users do
  get '/users/:id', to: 'users#show_one_week', as: 'show_one_week'

    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit'
      patch 'attendances/update_one_month' # AttendanceEditRequests実装前に上長へ申請せずに更新できる機能として実装。
      get 'monthly_requests/request_confirmation'
      get 'attending_index'
    end
    resources :attendances, only: :update
    resources :monthly_requests do
      collection do
        patch :request_update # ひと月分の勤怠申請に対する上長による判断
      end
    end
     get :monthly_requesting, :monthly_requesters  # 現在利用していない
    resources :over_time_requests
    resources :attendance_edit_requests # 勤怠編集申請
      post 'attendance_edit_requests/edited_table', to: 'attendance_edit_requests#edited_table' # ajaxのアクション
  end
  
end