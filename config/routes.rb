Rails.application.routes.draw do
  root "home#index"

  get "/register", to: "users#new"
  post "/register", to: "users#create"

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"

  delete "/logout", to: "sessions#destroy"

  resources :subjects, only: [:index]
  resources :tasks, only: [:index, :new]
  resource :profile, only: [:show]
end