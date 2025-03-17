# Error class for resource not found
class ResourceNotFoundError < ApplicationError
  def initialize(message = "Resource not found")
    super
  end
end
