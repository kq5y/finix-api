Rails.application.routes.draw do
  get "/hello" => "utils#hello"

  post "/auth/discord" => "sessions#auth"
  if Rails.env.development?
    get "/auth/discord" => "sessions#auth"
  end
  get "/auth/discord/callback" => "sessions#callback"

  get "/users/me" => "users#me"

  resources :categories, only: [ :index, :create, :update, :destroy ]
  resources :locations, only: [ :index, :create, :update, :destroy ]
  resources :payment_methods, only: [ :index, :create, :update, :destroy ]
  resources :expenditures, only: [ :index, :create, :update, :destroy ]

  root to: "error#not_found"
  match "*path" => "error#not_found", via: :all
end
