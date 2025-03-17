# Module for handling response and error messages
module ResponseHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActionController::ParameterMissing, with: :handle_invalid_parameter
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
    rescue_from Discard::RecordNotDiscarded, with: :handle_destroy_error
    rescue_from JWT::DecodeError, with: :handle_unauthorized
    rescue_from JWT::ExpiredSignature, with: :handle_unauthorized

    rescue_from ApplicationError, with: :handle_standard_error
    rescue_from ResourceNotFoundError, with: :handle_not_found
    rescue_from AuthenticationError, with: :handle_unauthorized
    rescue_from ValidationError, with: :handle_validation_error
  end

  private

  def render_success(data = nil, status = :ok)
    status_code = Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
    response = {
      meta: {
        status: status_code
      }
    }
    response[:data] = data if data
    render json: response, status: status
  end

  def render_error(message, status = :bad_request)
    status_code = Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
    error_response = {
      meta: {
        status: status_code,
        error_code: message
      }
    }
    render json: error_response, status: status
  end

  def handle_standard_error(error)
    Rails.logger.error "Unexpected error: #{error.message}\n#{error.backtrace&.join('\n')}"
    render_error(
      "SERVER_ERROR",
      :internal_server_error
    )
  end

  def handle_invalid_parameter
    render_error(
      "INVALID_PARAMETER",
      :bad_request
    )
  end

  def handle_not_found
    render_error(
      "NOT_FOUND",
      :not_found
    )
  end

  def handle_validation_error(error)
    Rails.logger.error "Validation error: #{error.message}"
    render_error(
      "VALIDATION_ERROR",
      :bad_request
    )
  end

  def handle_destroy_error
    render_error(
      "CANNOT_DELETE",
      :unprocessable_content
    )
  end

  def handle_unauthorized
    render_error(
      "UNAUTHORIZED",
      :unauthorized
    )
  end
end
