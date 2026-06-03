class AddContactToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :contact, :string
    add_column :users, :image, :string
  end
end
