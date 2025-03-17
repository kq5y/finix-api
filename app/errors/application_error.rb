# Base class for all application errors
class ApplicationError < StandardError
  def initialize(message = nil)
    super
  end
end
