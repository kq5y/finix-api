Rails.application.routes.draw do
  get "/hello" => "utils#hello"

  post "/auth/discord" => "sessions#auth"
  get "/auth/discord" => "sessions#auth" if Rails.env.development?
  get "/auth/discord/callback" => "sessions#callback"
  get "/logout" => "sessions#logout"

  get "/users/me" => "users#me"

  get "/summary" => "summary#index"

  resources :categories, only: %i[index show create update destroy]
  resources :locations, only: %i[index show create update destroy]
  resources :payment_methods, only: %i[index show create update destroy]
  resources :expenditures, only: %i[index show create update destroy]

  root to: "error#not_found"
  match "*path" => "error#not_found", via: :all
end
