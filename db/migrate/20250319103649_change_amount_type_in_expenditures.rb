class ChangeAmountTypeInExpenditures < ActiveRecord::Migration[8.0]
  def up
    # First convert existing decimal values to integers
    execute <<-SQL
      UPDATE expenditures
      SET amount = ROUND(amount)
      WHERE amount IS NOT NULL
    SQL

    change_column :expenditures, :amount, :integer
  end

  def down
    change_column :expenditures, :amount, :decimal, precision: 10, scale: 0
  end
end
