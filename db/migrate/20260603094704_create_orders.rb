class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :vendor, null: true, foreign_key: { to_table: :users }
      t.string :status, default: "pending", null: false
      t.decimal :total_amount, precision: 10, scale: 2, default: 0.0
      t.string :payment_status, default: "pending"
      t.text :delivery_address
      t.text :notes

      t.timestamps
    end

    add_index :orders, :status
    add_index :orders, :created_at
  end
end
