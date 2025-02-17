class SessionsController < ApplicationController
  skip_before_action :authenticate_request, only: [ :create ]

  def create
    user_info = request.env["omniauth.auth"]

    uid = user_info[:uid]
    username = user_info[:info][:name]
    avatar = user_info[:info][:image]

    token = generate_token(uid)

    user = User.find_by(uid: uid)

    if user
      user = User.update(user.id, uid: uid, username: username, avatar: avatar)
      cookies[:user_session] = { value: token, httponly: true }
      redirect_to "#{ENV["APP_BASE_URL"]}/login/callback?type=login", allow_other_host: true
    else
      user = User.create(uid: uid, username: username, avatar: avatar)
      cookies[:user_session] = { value: token, httponly: true }
      redirect_to "#{ENV["APP_BASE_URL"]}/login/callback?type=signup", allow_other_host: true
    end
  end

  private

  def generate_token(uid)
    exp = Time.now.to_i + 24 * 3600
    payload = { uid: uid, exp: exp }
    JWT.encode(payload, Rails.application.credentials.jwt.secret_key, "HS256")
  end
end
