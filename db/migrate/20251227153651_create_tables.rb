class CreateTables < ActiveRecord::Migration[8.0]
  def change
    create_table :tables do |t|
      t.references :tenant, null: false, foreign_key: true, index: true
      t.references :store, null: false, foreign_key: true, index: true
      t.string :number, null: false
      t.integer :capacity, default: 4
      t.integer :status, default: 0, null: false
      t.string :qr_code

      t.timestamps
    end

    # テーブル番号は店舗内でユニーク
    add_index :tables, [:store_id, :number], unique: true
    # QRコードはテナント内でユニーク
    add_index :tables, :qr_code, unique: true, where: "qr_code IS NOT NULL"
  end
end
