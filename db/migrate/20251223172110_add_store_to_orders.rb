class AddStoreToOrders < ActiveRecord::Migration[8.0]
  def change
    # 既存データがあるため、まず null: true で追加
    add_reference :orders, :store, null: true, foreign_key: true
    add_index :orders, [:store_id, :order_number], unique: true
    add_index :orders, [:store_id, :status]
  end
end
