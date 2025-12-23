class CreateStores < ActiveRecord::Migration[8.0]
  def change
    create_table :stores do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name, null: false
      t.string :address
      t.string :phone
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :stores, [:tenant_id, :name], unique: true
    add_index :stores, :active
  end
end
