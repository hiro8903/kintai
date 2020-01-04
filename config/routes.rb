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
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit'
      patch 'attendances/update_one_month'
    end
    resources :attendances, only: :update
  end
  
end