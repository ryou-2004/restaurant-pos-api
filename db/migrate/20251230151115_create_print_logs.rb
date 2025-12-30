class CreatePrintLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :print_logs do |t|
      t.references :tenant, null: false, foreign_key: true, index: true
      t.references :store, null: false, foreign_key: true, index: true
      t.references :order, null: false, foreign_key: true, index: true
      t.references :print_template, null: true, foreign_key: true
      t.datetime :printed_at, null: false
      t.string :status, null: false, default: 'success'
      t.text :error_message
      t.string :printer_name

      t.timestamps
    end

    add_index :print_logs, :printed_at
    add_index :print_logs, :status
  end
end
