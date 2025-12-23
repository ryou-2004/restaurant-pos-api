class AddStoreToKitchenQueues < ActiveRecord::Migration[8.0]
  def change
    # 既存データがあるため、まず null: true で追加
    add_reference :kitchen_queues, :store, null: true, foreign_key: true
    add_index :kitchen_queues, [:store_id, :status]
  end
end
