class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :label, default: "Home"
      t.text :address_line, null: false
      t.string :city, null: false
      t.string :state, null: false
      t.string :pincode, null: false
      t.boolean :is_default, default: false

      t.timestamps
    end
  end
end
