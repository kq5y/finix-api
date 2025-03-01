class ErrorController < ApplicationController
  def not_found
    raise ResourceNotFoundError.new("The requested page could not be found")
  end
end
