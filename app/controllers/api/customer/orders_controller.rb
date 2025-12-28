class Api::Customer::OrdersController < Api::Customer::BaseController
  def index
    # 自分のテーブルの未払い注文のみを返す
    @orders = current_tenant.orders
                          .where(table_id: current_table.id)
                          .where.not(status: :paid)
                          .includes(order_items: :menu_item)
                          .order(created_at: :desc)

    render json: @orders.map { |order| serialize_order(order) }
  end

  def create
    # 注文データを作成（table_idは自動設定）
    order_params_with_table = order_params.merge(
      table_id: current_table.id
    )

    # OrderServiceを使用して注文作成
    @order = OrderService.new(current_tenant).create_order(order_params_with_table)

    if @order.persisted?
      render json: serialize_order(@order), status: :created
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error "Customer order creation error: #{e.message}"
    render json: { error: '注文の作成に失敗しました' }, status: :internal_server_error
  end

  private

  def order_params
    params.require(:order).permit(
      :notes,
      order_items_attributes: [:menu_item_id, :quantity, :notes]
    )
  end

  def serialize_order(order)
    {
      id: order.id,
      order_number: order.order_number,
      status: order.status,
      table_id: order.table_id,
      total_amount: order.total_amount,
      notes: order.notes,
      order_items: order.order_items.map { |item| serialize_order_item(item) },
      created_at: order.created_at,
      updated_at: order.updated_at
    }
  end

  def serialize_order_item(item)
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
