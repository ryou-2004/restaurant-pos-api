class AddCategoryOrderToMenuItems < ActiveRecord::Migration[8.0]
  def change
    add_column :menu_items, :category_order, :integer, default: 0, null: false
    add_index :menu_items, :category_order
  end
end
