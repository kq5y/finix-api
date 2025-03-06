class PaymentMethodsController < ApplicationController
  before_action :authenticate_request
  before_action :set_payment_method, only: [ :show, :update, :destroy ]

  def index
    @payment_methods = @user.payment_methods

    # Sort
    @payment_methods = @payment_methods.apply_sort(params[:sort_key], params[:sort_order])

    # Paginate
    @payment_methods = @payment_methods.page(params[:page]).per(params[:page_size])

    render_success({ items: @payment_methods, total_count: @payment_methods.total_count })
  end

  def show
    render_success(@payment_method)
  end

  def create
    @payment_method = @user.payment_methods.new(payment_method_params)
    if @payment_method.save
      render_success(@payment_method, :created)
    else
      raise ValidationError.new(@payment_method.errors.full_messages.join(", "))
    end
  end

  def update
    if @payment_method.update(payment_method_params)
      render_success(@payment_method)
    else
      raise ValidationError.new(@payment_method.errors.full_messages.join(", "))
    end
  end

  def destroy
    if @payment_method.discard
      render_success(nil, :no_content)
    else
      raise Discard::RecordNotDiscarded.new("Failed to delete payment method", @payment_method)
    end
  end

  private

  def set_payment_method
    @payment_method = @user.payment_methods.find(params[:id])
  end

  def payment_method_params
    params.expect(payment_method: [ :name, :payment_type ])
  end
end
