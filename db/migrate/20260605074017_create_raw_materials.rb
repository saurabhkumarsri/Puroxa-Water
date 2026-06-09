class CreateRawMaterials < ActiveRecord::Migration[8.0]
  def change
    create_table :raw_materials do |t|
      t.string :name
      t.string :category
      t.integer :quantity
      t.string :unit
      t.integer :min_stock_level
      t.decimal :cost_per_unit
      t.string :supplier_name

      t.timestamps
    end
  end
end
