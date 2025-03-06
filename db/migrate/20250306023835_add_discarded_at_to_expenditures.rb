class AddDiscardedAtToExpenditures < ActiveRecord::Migration[8.0]
  def change
    add_column :expenditures, :discarded_at, :datetime
    add_index :expenditures, :discarded_at
  end
end
