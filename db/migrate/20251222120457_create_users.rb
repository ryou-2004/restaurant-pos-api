class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :email, null: false
      t.string :name, null: false
      t.string :password_digest, null: false
      t.integer :role, default: 0, null: false

      t.timestamps
    end

    add_index :users, [:tenant_id, :email], unique: true
    add_index :users, :role
  end
end
