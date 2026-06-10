class AddOnlineDiscountToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :online_discount_percent, :integer, default: 0, null: false
    add_column :orders, :online_discount_amount, :decimal, precision: 10, scale: 2, default: 0.0, null: false
  end
end
