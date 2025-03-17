# Validate required environment variables on application startup
required_variables = {
  "API_BASE_URL" => "The base URL for the API (e.g., https://api.example.com)",
  "APP_BASE_URL" => "The base URL for the frontend application (e.g., https://example.com)"
}

missing_variables = required_variables.select { |var, _| ENV[var].blank? }

if missing_variables.any?
  error_messages = missing_variables.map do |var, description|
    "#{var}: #{description}"
  end

  raise <<~ERROR
    Missing required environment variables:
    #{error_messages.join("\n")}

    Please ensure all required environment variables are set before starting the application.
  ERROR
end

# Validate URLs format
[
  ["API_BASE_URL", ENV.fetch("API_BASE_URL", nil)],
  ["APP_BASE_URL", ENV.fetch("APP_BASE_URL", nil)]
].each do |name, url|
  uri = URI.parse(url)
  raise "Must be an HTTP(S) URL" unless uri.scheme&.start_with?("http")
rescue URI::InvalidURIError, ArgumentError => e
  raise "Invalid #{name}: #{e.message}"
end

# Validate required credentials
raise "Missing Discord client_id in credentials" unless Rails.application.credentials.discord&.dig(:client_id)

raise "Missing Discord client_secret in credentials" unless Rails.application.credentials.discord&.dig(:client_secret)

raise "Missing JWT secret_key in credentials" unless Rails.application.credentials.jwt&.dig(:secret_key)
