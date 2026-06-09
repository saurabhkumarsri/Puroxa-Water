class AddDiscountToOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :orders, :discount, null: true, foreign_key: true
    add_column :orders, :discounted_amount, :decimal
  end
end
