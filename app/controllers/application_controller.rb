class ApplicationController < ActionController::API
  include ActionController::Cookies

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
    rescue ActiveRecord::RecordNotFound, JWT::ExpiredSignature, JWT::DecodeError
      render_error("Unauthorized", :unauthorized)
    end
  end

  private

  def render_success(data = nil, status = :ok)
    status_code = Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
    render json: { meta: { status: status_code }, data: data }, status: status
  end

  def render_error(code, status = :bad_request)
    status_code = Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
    render json: { meta: { status: status_code, error_code: code } }, status: status
  end
end
