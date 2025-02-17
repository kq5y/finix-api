Rails.application.routes.draw do
  get "/auth/discord/callback" => "sessions#create"
  get "/users/me" => "users#me"
end
