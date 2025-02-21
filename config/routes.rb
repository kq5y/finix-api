Rails.application.routes.draw do
  post "/auth/discord" => "sessions#auth"
  if Rails.env.development?
    get "/auth/discord" => "sessions#auth"
  end
  get "/auth/discord/callback" => "sessions#callback"

  get "/users/me" => "users#me"

  root to: "error#not_found"
  match "*path" => "error#not_found", via: :all
end
