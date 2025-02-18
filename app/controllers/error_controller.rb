class ErrorController < ApplicationController
  def not_found
    render_error("Not Found", :not_found)
  end
end
