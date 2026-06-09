class AddPaymentModeToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :payment_mode, :string, default: "cash"
  end
end
