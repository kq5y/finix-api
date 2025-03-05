class PaymentMethodsController < ApplicationController
  before_action :authenticate_request
  before_action :set_payment_method, only: [ :show, :update, :destroy ]

  def index
    @payment_methods = @user.payment_methods
    render_success({ items: @payment_methods })
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
    if @payment_method.destroy
      render_success()
    else
      raise ActiveRecord::RecordNotDestroyed.new("Failed to delete payment method", @payment_method)
    end
  end

  private

  def set_payment_method
    @payment_method = @user.payment_methods.find(params[:id])
  end

  def payment_method_params
    params.require(:payment_method).permit(:name, :method_type)
  end
end
