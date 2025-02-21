class SessionsController < ApplicationController
  def auth
    client_id = Rails.application.credentials.discord[:client_id]
    redirect_uri = "#{ENV["API_BASE_URL"]}/auth/discord/callback"
    scope = "identify"

    redirect_url = URI("https://discord.com/oauth2/authorize")
    redirect_url.query = URI.encode_www_form({
      response_type: "code",
      client_id: client_id,
      redirect_uri: redirect_uri,
      scope: scope
    })

    redirect_to redirect_url.to_s, allow_other_host: true
  end

  def callback
    begin
      if params[:error] || !params[:code]
        redirect_callback("error", 400)
        return
      end

      connection = Faraday.new("https://discord.com") do |f|
        f.request :url_encoded
        f.adapter Faraday.default_adapter
      end

      token_response = connection.post("/api/oauth2/token", {
        client_id: Rails.application.credentials.discord[:client_id],
        client_secret: Rails.application.credentials.discord[:client_secret],
        grant_type: "authorization_code",
        code: params[:code],
        redirect_uri: "#{ENV["API_BASE_URL"]}/auth/discord/callback"
      }, {
        "Content-Type" => "application/x-www-form-urlencoded"
      })
      access_token = JSON.parse(token_response.body)["access_token"]

      user_response = connection.get("/api/users/@me", nil, {
        "Authorization" => "Bearer #{access_token}"
      })
      user_info = JSON.parse(user_response.body)

      uid = user_info["id"]
      username = user_info["username"]
      avatar = "https://cdn.discordapp.com/avatars/#{uid}/#{user_info["avatar"]}"

      token = generate_token(uid)

      user = User.find_by(uid: uid)

      if user
        user = User.update(user.id, uid: uid, username: username, avatar: avatar)
        cookies[:user_session] = { value: token, httponly: true, expires: 1.day.from_now }
        redirect_callback("login")
      else
        user = User.create(uid: uid, username: username, avatar: avatar)
        cookies[:user_session] = { value: token, httponly: true, expires: 1.day.from_now }
        redirect_callback("signup")
      end
    rescue StandardError
      redirect_callback("error", 500)
    end
  end

  private

  def redirect_callback(type, code = nil)
    if code
      redirect_to "#{ENV["APP_BASE_URL"]}/login/callback?type=#{type}&code=#{code}", allow_other_host: true
    else
      redirect_to "#{ENV["APP_BASE_URL"]}/login/callback?type=#{type}", allow_other_host: true
    end
  end

  def generate_token(uid)
    exp = Time.now.to_i + 24 * 3600
    payload = { uid: uid, exp: exp }
    JWT.encode(payload, Rails.application.credentials.jwt.secret_key, "HS256")
  end
end
