class UsersController < ApplicationController
  before_action :authenticate_request, only: [ :me ]

  def me
    if @user
      render_success(@user)
    else
      raise AuthenticationError.new("ユーザー認証が必要です")
    end
  end
end
