class AddShopFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :shop_name, :string
    add_column :users, :area, :string
    add_column :users, :gst_number, :string
    add_column :users, :credit_limit, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
