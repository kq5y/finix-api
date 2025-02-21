class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ResponseHandler

  protected

  def authenticate_request
    token = cookies[:user_session]
    raise JWT::DecodeError, "No token provided" if token.blank?

    decoded = JWT.decode(
      token,
      Rails.application.credentials.jwt.secret_key,
      true,
      { algorithm: "HS256" }
    )

    @user = User.find_by!(uid: decoded[0]["uid"])
  end
end
