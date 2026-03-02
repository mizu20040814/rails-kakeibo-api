Rails.application.routes.draw do
  # * MEMO: Resousesで設定すれば、アクションが自動的にルーティングされる
  resources :expenses do
    collection do
      get :monthly_summary
      get :category_monthly_summary
      get :yearly_summary
      get :category_yearly_summary
    end
  end


  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
