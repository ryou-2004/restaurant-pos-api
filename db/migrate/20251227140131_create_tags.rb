class CreateTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags do |t|
      t.references :tenant, null: false, foreign_key: true, index: true
      t.string :name, null: false

      t.timestamps
    end

    # タグ名はテナント内でユニーク
    add_index :tags, [:tenant_id, :name], unique: true
  end
end
