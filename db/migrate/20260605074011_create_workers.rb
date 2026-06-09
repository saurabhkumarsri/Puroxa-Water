class CreateWorkers < ActiveRecord::Migration[8.0]
  def change
    create_table :workers do |t|
      t.string :name
      t.string :phone
      t.string :email
      t.text :address
      t.string :identity_type
      t.string :identity_number
      t.date :joining_date
      t.decimal :salary
      t.string :status
      t.string :emergency_contact
      t.text :notes

      t.timestamps
    end
  end
end
