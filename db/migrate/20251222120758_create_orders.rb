class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :order_number, null: false
      t.integer :table_id
      t.integer :status, default: 0, null: false
      t.integer :total_amount, default: 0, null: false
      t.text :notes

      t.timestamps
    end

    add_index :orders, [:tenant_id, :order_number], unique: true
    add_index :orders, :status
    add_index :orders, :table_id
    add_index :orders, :created_at
  end
end
