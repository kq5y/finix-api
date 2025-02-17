OmniAuth.config.allowed_request_methods = [ :post, :get ]

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :discord,
    Rails.application.credentials.discord[:client_id],
    Rails.application.credentials.discord[:client_secret],
    scope: "identify"
end
