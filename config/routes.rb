Rails.application.routes.draw do
  get "/live", to: redirect("/")
  root "home#index"

  get "/register", to: "users#new"
  post "/register", to: "users#create"

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"

  delete "/logout", to: "sessions#destroy"

  resources :subjects, only: [ :index, :create, :destroy ]
  resources :tasks, only: [ :index, :new, :create, :destroy ] do
    member do
      patch :complete
    end
  end
  resource :profile, only: [ :show ]
end
