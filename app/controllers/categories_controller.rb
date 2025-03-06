class CategoriesController < ApplicationController
  before_action :authenticate_request
  before_action :set_category, only: [ :show, :update, :destroy ]

  def index
    @categories = @user.categories

    # Sort
    @categories = @categories.apply_sort(params[:sort_key], params[:sort_order])

    # Paginate
    @categories = @categories.page(params[:page]).per(params[:page_size])

    render_success({ items: @categories, total_count: @categories.total_count })
  end

  def show
    render_success(@category)
  end

  def create
    @category = @user.categories.new(category_params)
    if @category.save
      render_success(@category, :created)
    else
      raise ValidationError.new(@category.errors.full_messages.join(", "))
    end
  end

  def update
    if @category.update(category_params)
      render_success(@category)
    else
      raise ValidationError.new(@category.errors.full_messages.join(", "))
    end
  end

  def destroy
    if @category.discard
      render_success(nil, :no_content)
    else
      raise Discard::RecordNotDiscarded.new("Failed to delete category", @category)
    end
  end

  private

  def set_category
    @category = @user.categories.find(params[:id])
  end

  def category_params
    params.expect(category: [ :name ])
  end
end
