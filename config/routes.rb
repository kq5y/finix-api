Rails.application.routes.draw do
  get "/auth/discord/callback" => "sessions#create"
  get "/auth/failure" => "sessions#failure"

  get "/users/me" => "users#me"

  root to: "error#not_found"
  match "*path" => "error#not_found", via: :all
end
