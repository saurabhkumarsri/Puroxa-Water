class CreateDiscounts < ActiveRecord::Migration[8.0]
  def change
    create_table :discounts do |t|
      t.string :code
      t.string :discount_type
      t.decimal :value
      t.decimal :min_order_amount
      t.date :expiry_date
      t.integer :usage_limit
      t.integer :usage_count
      t.boolean :active

      t.timestamps
    end
  end
end
