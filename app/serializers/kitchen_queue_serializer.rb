class KitchenQueueSerializer
  def initialize(kitchen_queue)
    @kitchen_queue = kitchen_queue
  end

  def as_json(options = {})
    {
      id: @kitchen_queue.id,
      status: @kitchen_queue.status,
      priority: @kitchen_queue.priority,
      estimated_cooking_time: @kitchen_queue.estimated_cooking_time,
      cooking_time_minutes: @kitchen_queue.cooking_time_minutes,
      started_at: @kitchen_queue.started_at,
      completed_at: @kitchen_queue.completed_at,
      notes: @kitchen_queue.notes,
      order: order_json,
      created_at: @kitchen_queue.created_at,
      updated_at: @kitchen_queue.updated_at
    }
  end

  private

  def order_json
    return nil unless @kitchen_queue.order

    {
      id: @kitchen_queue.order.id,
      order_number: @kitchen_queue.order.order_number,
      table_number: @kitchen_queue.order.table_number,
      notes: @kitchen_queue.order.notes,
      order_items: order_items_json
    }
  end

  def order_items_json
    @kitchen_queue.order.order_items.map do |item|
      {
        id: item.id,
        menu_item_name: item.menu_item_name,
        quantity: item.quantity,
        notes: item.notes
      }
    end
  end
end
