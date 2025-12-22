class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :tenant, null: false, foreign_key: true
      t.integer :plan, default: 0, null: false
      t.boolean :realtime_enabled, default: false, null: false
      t.boolean :polling_enabled, default: false, null: false
      t.integer :max_stores, default: 1, null: false
      t.datetime :expires_at

      t.timestamps
    end

    add_index :subscriptions, :plan
    add_index :subscriptions, :expires_at
  end
end
