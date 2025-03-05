class AddPaymentMethodIdToExpenditures < ActiveRecord::Migration[8.0]
  def change
    add_reference :expenditures, :payment_method, null: false, foreign_key: true
  end
end
