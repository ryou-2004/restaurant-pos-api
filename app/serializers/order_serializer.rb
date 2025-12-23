class OrderSerializer
  def initialize(order)
    @order = order
  end

  def as_json(options = {})
    {
      id: @order.id,
      order_number: @order.order_number,
      status: @order.status,
      table_number: @order.table_number,
      total_amount: @order.total_amount,
      item_count: @order.item_count,
      notes: @order.notes,
      order_items: order_items_json,
      created_at: @order.created_at,
      updated_at: @order.updated_at
    }
  end

  private

  def order_items_json
    @order.order_items.map do |item|
      {
        id: item.id,
        menu_item_id: item.menu_item_id,
        menu_item_name: item.menu_item_name,
        quantity: item.quantity,
        unit_price: item.unit_price,
        subtotal: item.subtotal,
        notes: item.notes
      }
    end
  end
end
