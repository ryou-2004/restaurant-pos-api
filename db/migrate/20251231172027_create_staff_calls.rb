class CreateStaffCalls < ActiveRecord::Migration[8.0]
  def change
    create_table :staff_calls do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :store, null: false, foreign_key: true
      t.references :table, null: false, foreign_key: true
      t.references :table_session, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.string :call_type, default: 'general', null: false
      t.datetime :resolved_at
      t.integer :resolved_by_id
      t.text :notes

      t.timestamps
    end

    add_index :staff_calls, [:store_id, :status, :created_at], name: 'index_staff_calls_on_store_status_created'
    add_index :staff_calls, [:table_session_id, :status], name: 'index_staff_calls_on_session_status'
  end
end
