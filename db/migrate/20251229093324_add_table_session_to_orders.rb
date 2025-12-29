class AddTableSessionToOrders < ActiveRecord::Migration[8.0]
  def change
    # table_session_id を追加（nullable、既存レコード対応）
    add_reference :orders, :table_session, foreign_key: true, index: true

    # status enum から 'paid' を削除するため、既存の paid レコードを delivered に変更
    # ※本番運用前のため、開発環境のデータクリアで対応
  end
end
