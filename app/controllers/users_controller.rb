# Controller for user model
class UsersController < ApplicationController
  before_action :authenticate_request, only: %i[me]

  def me
    raise AuthenticationError, "ユーザー認証が必要です" unless @user

    render_success(@user)
  end
end
