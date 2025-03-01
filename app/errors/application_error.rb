class ApplicationError < StandardError
  def initialize(message = nil)
    super(message)
  end
end

class ResourceNotFoundError < ApplicationError
  def initialize(message = "Resource not found")
    super(message)
  end
end

class AuthenticationError < ApplicationError
  def initialize(message = "Authentication failed")
    super(message)
  end
end

class ValidationError < ApplicationError
  def initialize(message = "Validation failed")
    super(message)
  end
end
