Rails.application.routes.draw do
  devise_for :users
  
  namespace :api do
    namespace :v1 do
      post 'auth/login', to: 'auth#login'
      delete 'auth/logout', to: 'auth#logout'
      get 'auth/current_user', to: 'auth#current_user_info'
      resources :notes
    end
  end
  
  get "up" => "rails/health#show", as: :rails_health_check
end
