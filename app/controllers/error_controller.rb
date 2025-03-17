# Controller for handling errors
class ErrorController < ApplicationController
  def not_found
    raise ResourceNotFoundError, "The requested page could not be found"
  end
end
