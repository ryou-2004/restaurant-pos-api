class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.integer :payment_method, null: false
      t.integer :amount, null: false
      t.integer :status, default: 0, null: false
      t.datetime :paid_at

      t.timestamps
    end

    add_index :payments, :status
    add_index :payments, :payment_method
    add_index :payments, [:tenant_id, :created_at]
  end
end
