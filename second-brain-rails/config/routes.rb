Rails.application.routes.draw do
  devise_for :users
  root "notes#index"
  resources :notes
  resource :profile, only: [:show]
  get "up" => "rails/health#show", as: :rails_health_check
end
  post 'notes/:id/receive_rhythm', to: 'notes#receive_rhythm'
