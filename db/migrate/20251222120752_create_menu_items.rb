class CreateMenuItems < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_items do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :price, null: false
      t.string :category, null: false
      t.boolean :available, default: true, null: false

      t.timestamps
    end

    add_index :menu_items, :category
    add_index :menu_items, :available
    add_index :menu_items, [:tenant_id, :name]
  end
end
