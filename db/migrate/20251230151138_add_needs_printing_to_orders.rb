class AddNeedsPrintingToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :needs_printing, :boolean, default: false
    add_column :orders, :printed_at, :datetime
  end
end
