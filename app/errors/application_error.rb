class ApplicationError < StandardError
  attr_reader :status

  def initialize(message = nil, status = :bad_request)
    @status = status
    super(message)
  end
end

class ResourceNotFoundError < ApplicationError
  def initialize(message = "Resource not found")
    super(message, :not_found)
  end
end

class AuthenticationError < ApplicationError
  def initialize(message = "Authentication failed")
    super(message, :unauthorized)
  end
end

class ValidationError < ApplicationError
  def initialize(message = "Validation failed")
    super(message, :unprocessable_entity)
  end
end
