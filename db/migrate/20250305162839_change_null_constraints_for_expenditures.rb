class ChangeNullConstraintsForExpenditures < ActiveRecord::Migration[8.0]
  def change
    change_column_null :expenditures, :category_id, true
    change_column_null :expenditures, :location_id, true
    change_column_null :expenditures, :payment_method_id, true
  end
end
