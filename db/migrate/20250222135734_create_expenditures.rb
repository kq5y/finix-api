class CreateExpenditures < ActiveRecord::Migration[8.0]
  def change
    create_table :expenditures do |t|
      t.decimal :amount
      t.text :description
      t.date :date
      t.references :category, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
