class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.integer :rating, null: false
      t.text :comment
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :order, null: false, foreign_key: true
      t.references :vendor, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :reviews, [:order_id], unique: true, name: "index_reviews_on_order_id_unique"
  end
end
