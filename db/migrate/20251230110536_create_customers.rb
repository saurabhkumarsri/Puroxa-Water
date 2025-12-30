class CreateCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :customers do |t|
      t.string :shop_name
      t.string :contact_number
      t.text :address
      t.boolean :approved
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
