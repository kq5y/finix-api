# Service class for Discord OAuth2 authentication
class DiscordAuthService
  class Error < StandardError; end
  class InvalidTokenError < Error; end
  class InvalidUserError < Error; end
  class ApiError < Error; end

  def initialize
    validate_environment_variables!
    @connection = build_connection
  end

  def authorization_url(state = nil)
    url = URI("https://discord.com/oauth2/authorize")
    url.query = URI.encode_www_form({
      response_type: "code",
      client_id: client_id,
      redirect_uri: callback_url,
      scope: "identify",
      state: state
    }.compact)
    url.to_s
  end

  def authenticate(code)
    token = fetch_token(code)
    user_info = fetch_user_info(token)

    {
      uid: user_info["id"],
      username: user_info["username"],
      avatar: build_avatar_url(user_info["id"], user_info["avatar"])
    }
  end

  private

  def validate_environment_variables!
    missing_vars = []
    missing_vars << "API_BASE_URL" if ENV["API_BASE_URL"].blank?
    missing_vars << "Discord client_id" if client_id.blank?
    missing_vars << "Discord client_secret" if client_secret.blank?

    return unless missing_vars.any?

    raise Error, "Missing required environment variables: #{missing_vars.join(', ')}"
  end

  def fetch_token(code)
    response = @connection.post(
      "/api/oauth2/token",
      {
        client_id: client_id,
        client_secret: client_secret,
        grant_type: "authorization_code",
        code: code,
        redirect_uri: callback_url
      }, {
        "Content-Type" => "application/x-www-form-urlencoded"
      }
    )

    validate_response!(response)
    parsed_response = parse_json(response.body)

    raise InvalidTokenError, "Access token not found in response" if parsed_response["access_token"].blank?

    parsed_response["access_token"]
  end

  def fetch_user_info(access_token)
    response = @connection.get("/api/users/@me", nil, { "Authorization" => "Bearer #{access_token}" })

    validate_response!(response)
    user_info = parse_json(response.body)

    validate_user_info!(user_info)
    user_info
  end

  def validate_response!(response)
    return if response.success?

    raise ApiError, "Discord API error: #{response.status} - #{response.body}"
  end

  def validate_user_info!(user_info)
    required_fields = %w[id username avatar]
    missing_fields = required_fields.select { |field| user_info[field].nil? }

    return unless missing_fields.any?

    raise InvalidUserError, "Missing required user fields: #{missing_fields.join(', ')}"
  end

  def parse_json(body)
    JSON.parse(body)
  rescue JSON::ParserError
    raise Error, "Invalid JSON response from Discord API"
  end

  def build_avatar_url(uid, avatar)
    "https://cdn.discordapp.com/avatars/#{uid}/#{avatar}"
  end

  def build_connection
    Faraday.new("https://discord.com") do |f|
      f.request :url_encoded
      f.adapter Faraday.default_adapter
    end
  end

  def callback_url
    "#{ENV.fetch('API_BASE_URL', nil)}/auth/discord/callback"
  end

  def client_id
    Rails.application.credentials.discord[:client_id]
  end

  def client_secret
    Rails.application.credentials.discord[:client_secret]
  end
end
