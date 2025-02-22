class CreatePaymentMethods < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_methods do |t|
      t.string :name
      t.string :payment_type
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
