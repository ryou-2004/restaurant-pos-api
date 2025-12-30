class CreateActivityLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :activity_logs do |t|
      # ========================================
      # ポリモーフィック関連（誰が操作したか）
      # ========================================
      t.string :user_type, null: false
      t.bigint :user_id, null: false

      # ========================================
      # テナント・店舗情報（スコープ制御）
      # ========================================
      t.bigint :tenant_id
      t.bigint :store_id

      # ========================================
      # アクションタイプ
      # ========================================
      t.string :action_type, null: false

      # ========================================
      # 操作対象リソース（ポリモーフィック）
      # ========================================
      t.string :resource_type
      t.bigint :resource_id

      # ========================================
      # メタデータ（JSONB）
      # ========================================
      t.jsonb :metadata, default: {}, null: false

      # ========================================
      # リクエスト情報
      # ========================================
      t.string :ip_address
      t.string :user_agent

      # ========================================
      # タイムスタンプ
      # ========================================
      t.timestamps
    end

    # ========================================
    # インデックス（パフォーマンス最適化）
    # ========================================
    # ポリモーフィック関連用
    add_index :activity_logs, [:user_type, :user_id], name: 'index_activity_logs_on_user'
    add_index :activity_logs, [:resource_type, :resource_id], name: 'index_activity_logs_on_resource'

    # スコープ・検索用
    add_index :activity_logs, :tenant_id
    add_index :activity_logs, :store_id
    add_index :activity_logs, :action_type
    add_index :activity_logs, :created_at

    # 複合インデックス（頻繁な検索パターン）
    add_index :activity_logs, [:tenant_id, :created_at], name: 'index_activity_logs_on_tenant_and_created_at'
    add_index :activity_logs, [:store_id, :created_at], name: 'index_activity_logs_on_store_and_created_at'
    add_index :activity_logs, [:tenant_id, :action_type, :created_at], name: 'index_activity_logs_on_tenant_action_created'
    add_index :activity_logs, [:user_type, :user_id, :created_at], name: 'index_activity_logs_on_user_and_created_at'

    # JSONB カラム用（GIN インデックス）
    add_index :activity_logs, :metadata, using: :gin

    # ========================================
    # 外部キー制約
    # ========================================
    add_foreign_key :activity_logs, :tenants, column: :tenant_id, on_delete: :cascade
    add_foreign_key :activity_logs, :stores, column: :store_id, on_delete: :cascade
  end
end
