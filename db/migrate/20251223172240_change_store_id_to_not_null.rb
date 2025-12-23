class ChangeStoreIdToNotNull < ActiveRecord::Migration[8.0]
  def change
    # データ移行完了後、NOT NULL 制約を追加
    change_column_null :orders, :store_id, false
    change_column_null :kitchen_queues, :store_id, false
  end
end
