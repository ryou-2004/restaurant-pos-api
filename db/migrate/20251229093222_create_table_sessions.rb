class CreateTableSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :table_sessions do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :store, null: false, foreign_key: true
      t.integer :table_id, null: false
      t.integer :party_size
      t.integer :status, default: 0, null: false
      t.datetime :started_at, null: false
      t.datetime :ended_at

      t.timestamps
    end

    # インデックス追加
    add_index :table_sessions, :table_id
    add_index :table_sessions, :status
    add_index :table_sessions, :started_at
    add_index :table_sessions, [:store_id, :table_id, :status], name: 'index_table_sessions_on_store_table_status'
  end
end
