class AddDiscardedAt < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :discarded_at, :datetime
    add_index :users, :discarded_at
    add_column :locations, :discarded_at, :datetime
    add_index :locations, :discarded_at
    add_column :categories, :discarded_at, :datetime
    add_index :categories, :discarded_at
    add_column :payment_methods, :discarded_at, :datetime
    add_index :payment_methods, :discarded_at
  end
end
