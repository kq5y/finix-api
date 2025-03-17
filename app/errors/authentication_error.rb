# Error class for authentication errors
class AuthenticationError < ApplicationError
  def initialize(message = "Authentication failed")
    super
  end
end
