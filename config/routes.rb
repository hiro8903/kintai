Rails.application.routes.draw do
  # get 'static_pages/top'  「$ rails generate controller StaticPages top 」で自動生成されたルーティング
  root 'static_pages#top'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
