class CreateStaffUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :staff_users do |t|
      t.string :email, null: false
      t.string :name, null: false
      t.string :password_digest, null: false
      t.integer :role, default: 0, null: false

      t.timestamps
    end

    add_index :staff_users, :email, unique: true
    add_index :staff_users, :role
  end
end
