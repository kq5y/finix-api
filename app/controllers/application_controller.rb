class ApplicationController < ActionController::API
  include ActionController::Cookies
  before_action :authenticate_request

  protected

  def authenticate_request
    token = cookies[:user_session]
    begin
      decoded = JWT.decode(
        token,
        Rails.application.credentials.jwt.secret_key,
        true,
        { algorithm: "HS256" }
      )
      @user = User.find_by(uid: decoded[0]["uid"])
      unless @user
        raise ActiveRecord::RecordNotFound, "User not found"
      end
    rescue ActiveRecord::RecordNotFound, JWT::ExpiredSignature, JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end
end
