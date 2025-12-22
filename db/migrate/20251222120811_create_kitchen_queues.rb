class CreateKitchenQueues < ActiveRecord::Migration[8.0]
  def change
    create_table :kitchen_queues do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.integer :priority, default: 0, null: false
      t.integer :estimated_cooking_time
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :kitchen_queues, :status
    add_index :kitchen_queues, :priority
    add_index :kitchen_queues, :started_at
    add_index :kitchen_queues, [:tenant_id, :status]
  end
end
