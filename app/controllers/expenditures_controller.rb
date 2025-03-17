class ExpendituresController < ApplicationController
  before_action :authenticate_request
  before_action :set_expenditure, only: [ :show, :update, :destroy ]

  def index
    # Check safe params
    if (params[:start_date] && !params[:start_date].match(/\A\d{4}-\d{2}-\d{2}\z/)) ||
        (params[:end_date] && !params[:end_date].match(/\A\d{4}-\d{2}-\d{2}\z/)) ||
        (params[:sort_order] && !Expenditure::VALID_SORT_ORDERS.include?(params[:sort_order].to_sym)) ||
        (params[:sort_key] && !Expenditure::VALID_SORT_KEYS.include?(params[:sort_key]))
      raise ActionController::ParameterMissing.new("Invalid parameters")
    end

    @expenditures = @user.expenditures

    # Filter by category, location and payment method
    @expenditures = @expenditures.where(category_id: params[:category_id]) if params[:category_id]
    @expenditures = @expenditures.where(location_id: params[:location_id]) if params[:location_id]
    @expenditures = @expenditures.where(payment_method_id: params[:payment_method_id]) if params[:payment_method_id]

    # Filter by date range
    @expenditures = @expenditures.where("date >= ?", params[:start_date]) if params[:start_date]
    @expenditures = @expenditures.where("date <= ?", params[:end_date]) if params[:end_date]

    # Sort
    @expenditures = @expenditures.apply_sort(params[:sort_key], params[:sort_order])

    # Paginate
    @expenditures = @expenditures.page(params[:page]).per(params[:page_size])

    render_success({
      items: @expenditures,
      total_count: @expenditures.total_count
    })
  end

  def show
    render_success(@expenditure)
  end

  def create
    @expenditure = @user.expenditures.new(expenditure_params)
    if @expenditure.save
      render_success(@expenditure, :created)
    else
      raise ValidationError.new(@expenditure.errors.full_messages.join(", "))
    end
  end

  def update
    if @expenditure.update(expenditure_params)
      render_success(@expenditure)
    else
      raise ValidationError.new(@expenditure.errors.full_messages.join(", "))
    end
  end

  def destroy
    if @expenditure.discard
      render_success(nil)
    else
      raise Discard::RecordNotDiscarded.new("Failed to delete expenditure", @expenditure)
    end
  end

  private

  def set_expenditure
    @expenditure = @user.expenditures.find(params[:id])
  end

  def expenditure_params
    params.expect(expenditure: [ :amount, :description, :date, :category_id, :location_id, :payment_method_id ])
  end
end
