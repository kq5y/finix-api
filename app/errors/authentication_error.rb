class AuthenticationError < ApplicationError
  def initialize(message = "Authentication failed")
    super(message)
  end
end
