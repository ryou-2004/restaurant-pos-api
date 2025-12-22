class CreateOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :menu_item, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.integer :unit_price, null: false
      t.text :notes

      t.timestamps
    end

    add_index :order_items, [:order_id, :menu_item_id]
  end
end
