# Error class for validation error
class ValidationError < ApplicationError
  def initialize(message = "Validation failed")
    super
  end
end
