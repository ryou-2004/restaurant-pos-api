class MigrateTenantDataToStores < ActiveRecord::Migration[8.0]
  def up
    # 各テナントに対してデフォルトの店舗を作成
    Tenant.find_each do |tenant|
      store = tenant.stores.create!(
        name: "#{tenant.name} 本店",
        active: true
      )

      # 既存の注文をこの店舗に紐付け
      tenant.orders.update_all(store_id: store.id)

      # 既存の厨房キューをこの店舗に紐付け
      tenant.kitchen_queues.update_all(store_id: store.id)
    end
  end

  def down
    # ロールバック時は store_id を NULL に戻す（NOT NULL制約を一時的に解除する必要あり）
    # 実際の運用では down は実装しないことを推奨
    raise ActiveRecord::IrreversibleMigration
  end
end
