class SessionsController < ApplicationController
  def auth
    auth_service = DiscordAuthService.new
    redirect_to auth_service.authorization_url, allow_other_host: true
  rescue DiscordAuthService::Error => e
    Rails.logger.error "Discord authorization error: #{e.message}"
    redirect_callback("error", 500)
  end

  def callback
    handle_callback
  rescue DiscordAuthService::InvalidTokenError
    Rails.logger.error "Invalid token received from Discord"
    redirect_callback("error", 401)
  rescue DiscordAuthService::InvalidUserError
    Rails.logger.error "Invalid user data received from Discord"
    redirect_callback("error", 400)
  rescue DiscordAuthService::ApiError => e
    Rails.logger.error "Discord API error: #{e.message}"
    redirect_callback("error", 503)
  rescue DiscordAuthService::Error => e
    Rails.logger.error "Discord authentication error: #{e.message}"
    redirect_callback("error", 500)
  rescue StandardError => e
    Rails.logger.error "Unexpected error during authentication: #{e.message}"
    redirect_callback("error", 500)
  end

  private

  def handle_callback
    if params[:error].present? || !params[:code].present?
      redirect_callback("error", 400)
      return
    end

    auth_service = DiscordAuthService.new
    user_data = auth_service.authenticate(params[:code])

    user = find_or_create_user(user_data)
    token = generate_token(user.uid)

    set_session_cookie(token)
    redirect_callback(user.created_at == user.updated_at ? "signup" : "login")
  end

  def find_or_create_user(user_data)
    user = User.find_by(uid: user_data[:uid])

    if user
      user.update!(
        username: user_data[:username],
        avatar: user_data[:avatar]
      )
    else
      user = User.create!(user_data)
    end

    user
  end

  def set_session_cookie(token)
    cookies[:user_session] = {
      value: token,
      httponly: true,
      expires: 1.day.from_now
    }
  end

  def redirect_callback(type, code = nil)
    url = "#{ENV['APP_BASE_URL']}/login/callback"
    params = { type: type }
    params[:code] = code if code.present?

    redirect_to "#{url}?#{params.to_query}", allow_other_host: true
  end

  def generate_token(uid)
    exp = Time.now.to_i + 24 * 3600
    payload = { uid: uid, exp: exp }
    JWT.encode(payload, Rails.application.credentials.jwt.secret_key, "HS256")
  end
end
