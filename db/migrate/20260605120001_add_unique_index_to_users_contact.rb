class AddUniqueIndexToUsersContact < ActiveRecord::Migration[8.0]
  def change
    add_index :users, :contact, unique: true
  end
end
