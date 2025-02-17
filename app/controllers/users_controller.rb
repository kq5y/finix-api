class UsersController < ApplicationController
  def me
    if @user
      render json: { user: @user }
    else
      render json: { error: "No user logged in" }, status: :unauthorized
    end
  end
end
