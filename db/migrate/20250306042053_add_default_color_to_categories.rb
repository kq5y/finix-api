class AddDefaultColorToCategories < ActiveRecord::Migration[8.0]
  def up
    execute "UPDATE categories SET color = '#D3D3D3' WHERE color IS NULL"
    change_column :categories, :color, :string, null: false, default: '#D3D3D3'
  end

  def down
    change_column :categories, :color, :string, null: true, default: nil
  end
end
