class UsersController < ApplicationController
  before_action :authenticate_request, only: [ :me ]

  def me
    if @user
      render_success({ user: @user })
    else
      render_error("Unauthorized", :unauthorized)
    end
  end
end
