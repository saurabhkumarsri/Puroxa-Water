class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.string :title, null: false
      t.text :body
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :order, foreign_key: true
      t.boolean :read, default: false, null: false

      t.timestamps
    end
  end
end
