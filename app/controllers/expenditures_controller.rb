class ExpendituresController < ApplicationController
  before_action :authenticate_request
  before_action :set_expenditure, only: [ :update, :destroy ]

  def index
    @expenditures = @user.expenditures
    @expenditures = @expenditures.where(date: params[:start_date]..params[:end_date]) if params[:start_date] && params[:end_date]
    @expenditures = @expenditures.where(category_id: params[:category_id]) if params[:category_id]
    render_success({ expenditures: @expenditures })
  end

  def create
    @expenditure = @user.expenditures.new(expenditure_params)
    if @expenditure.save
      render_success({ expenditure: @expenditure }, :created)
    else
      render_error("Expenditure not created")
    end
  end

  def update
    if @expenditure.update(expenditure_params)
      render_success({ expenditure: @expenditure })
    else
      render_error("Expenditure not updated")
    end
  end

  def destroy
    if @expenditure.destroy
      render_success()
    else
      render_error("Expenditure not deleted")
    end
  end

  private

  def set_expenditure
    @expenditure = @user.expenditures.find(params[:id])
  end

  def expenditure_params
    params.require(:expenditure).permit(:amount, :description, :date, :category_id)
  end
end
