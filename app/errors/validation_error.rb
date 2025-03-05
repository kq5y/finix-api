class ValidationError < ApplicationError
  def initialize(message = "Validation failed")
    super(message)
  end
end
