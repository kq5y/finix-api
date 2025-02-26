class CategoriesController < ApplicationController
  before_action :authenticate_request
  before_action :set_category, only: [ :update, :destroy ]

  def index
    @categories = @user.categories
    render_success({ items: @categories })
  end

  def create
    @category = @user.categories.new(category_params)
    if @category.save
      render_success({ category: @category }, :created)
    else
      render_error("Category not created")
    end
  end

  def update
    if @category.update(category_params)
      render_success({ category: @category })
    else
      render_error("Category not updated")
    end
  end

  def destroy
    if @category.destroy
      render_success()
    else
      render_error("Category not deleted")
    end
  end

  private

  def set_category
    @category = @user.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end
