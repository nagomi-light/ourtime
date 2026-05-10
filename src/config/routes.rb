Rails.application.routes.draw do
  devise_for :users
  root to: "events#index"
  resources :events
  resources :teams
  
  namespace :admin do
    get "teams/index"
    get "teams/show"
    get "teams/new"
    get "teams/create"
    get "teams/edit"
    get "teams/destroy"
    resources :users
    resources :teams
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
