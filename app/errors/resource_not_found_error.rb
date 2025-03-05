class ResourceNotFoundError < ApplicationError
  def initialize(message = "Resource not found")
    super(message)
  end
end
