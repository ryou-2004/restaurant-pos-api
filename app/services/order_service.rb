class OrderService
  def initialize(tenant)
    @tenant = tenant
  end

  # 注文作成の一連の処理をトランザクションで実行
  def create_order(params)
    Rails.logger.debug "=== OrderService#create_order ==="
    Rails.logger.debug "params: #{params.inspect}"
    Rails.logger.debug "order_items_attributes: #{params[:order_items_attributes].inspect}"

    ActiveRecord::Base.transaction do
      order = build_order(params)
      add_order_items(order, params[:order_items_attributes])
      calculate_and_set_total(order)
      create_kitchen_queue(order)
      broadcast_new_order(order) if realtime_enabled?

      order
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "注文作成失敗: #{e.message}"
    raise
  end

  # 注文更新
  def update_order(order, params)
    ActiveRecord::Base.transaction do
      order.update!(params)
      calculate_and_set_total(order) if params[:order_items_attributes].present?
      broadcast_order_update(order) if realtime_enabled?

      order
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "注文更新失敗: #{e.message}"
    raise
  end

  private

  def build_order(params)
    @tenant.orders.create!(
      table_id: params[:table_id],
      notes: params[:notes],
      status: :pending
    )
  end

  def add_order_items(order, items_params)
    Rails.logger.debug "=== add_order_items ==="
    Rails.logger.debug "items_params.blank?: #{items_params.blank?}"
    Rails.logger.debug "items_params.class: #{items_params.class}"

    return if items_params.blank?

    items_params.each do |item_params|
      Rails.logger.debug "item_params: #{item_params.inspect}"
      Rails.logger.debug "menu_item_id: #{item_params[:menu_item_id]}"

      menu_item = @tenant.menu_items.find(item_params[:menu_item_id])

      order.order_items.create!(
        menu_item: menu_item,
        quantity: item_params[:quantity],
        unit_price: menu_item.price,
        notes: item_params[:notes]
      )
    end
  end

  def calculate_and_set_total(order)
    total = order.calculate_total
    order.update_column(:total_amount, total)
  end

  def create_kitchen_queue(order)
    KitchenQueue.create_from_order(order)
  end

  def broadcast_new_order(order)
    ActionCable.server.broadcast(
      "tenant_#{@tenant.id}_kitchen",
      {
        type: 'new_order',
        order: OrderSerializer.new(order).as_json
      }
    )
  end

  def broadcast_order_update(order)
    ActionCable.server.broadcast(
      "tenant_#{@tenant.id}_orders",
      {
        type: 'order_updated',
        order: OrderSerializer.new(order).as_json
      }
    )
  end

  def realtime_enabled?
    @tenant.subscription&.realtime_enabled?
  end
end
