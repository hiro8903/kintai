Rails.application.routes.draw do
  
=begin
  「rails g コマンドで自動生成されたルーティング」
    get 'users/new'
    get 'static_pages/top' 
=end

  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
end
