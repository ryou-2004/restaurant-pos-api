class CreateTenantUserTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tenant_user_tags do |t|
      t.references :tenant_user, null: false, foreign_key: true, index: true
      t.references :tag, null: false, foreign_key: true, index: true

      t.timestamps
    end

    # 同じユーザーに同じタグを複数回付与することを防ぐ
    add_index :tenant_user_tags, [:tenant_user_id, :tag_id], unique: true
  end
end
