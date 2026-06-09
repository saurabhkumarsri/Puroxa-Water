class AddBottlesPerPackToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :bottles_per_pack, :integer, default: 1, null: false
  end
end
