class UpdatePaymentsForTableSession < ActiveRecord::Migration[8.0]
  def change
    # order_id の外部キー制約を削除
    remove_foreign_key :payments, :orders if foreign_key_exists?(:payments, :orders)

    # order_id のインデックスを削除
    remove_index :payments, :order_id if index_exists?(:payments, :order_id)

    # order_id カラムを削除
    remove_column :payments, :order_id, :bigint

    # table_session_id を追加
    add_reference :payments, :table_session, foreign_key: true, index: true
  end
end
