class Api::Customer::OrdersController < Api::Customer::BaseController
  include Loggable

  def index
    # 自分のテーブルセッションの注文を返す（会計前のアクティブなセッション）
    @orders = current_table_session.orders
                                   .includes(order_items: :menu_item)
                                   .order(created_at: :desc)

    render json: @orders.map { |order| serialize_order(order) }
  end

  def create
    # 注文データを作成（table_idとtable_session_idは自動設定）
    order_params_with_context = order_params.merge(
      table_id: current_table.id,
      table_session_id: current_table_session.id
    )

    # OrderServiceを使用して注文作成
    @order = OrderService.new(current_tenant).create_order(order_params_with_context)

    if @order.persisted?
      render json: serialize_order(@order), status: :created
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error "Customer order creation error: #{e.message}"
    render json: { error: '注文の作成に失敗しました' }, status: :internal_server_error
  end

  # 注文キャンセル（調理前のみ）
  def cancel
    @order = current_table_session.orders.find(params[:id])

    unless @order.can_cancel?
      render json: { error: 'この注文はキャンセルできません。調理が開始されている可能性があります。' }, status: :unprocessable_entity
      return
    end

    @order.cancel!(params[:cancellation_reason] || 'お客様都合')

    # キャンセルログ記録
    log_business_event(:order_cancelled, @order, metadata: {
      order_number: @order.order_number,
      total_amount: @order.total_amount,
      cancellation_reason: @order.cancellation_reason,
      item_count: @order.order_items.count
    })

    render json: serialize_order(@order), status: :ok
  rescue StandardError => e
    Rails.logger.error "Order cancellation error: #{e.message}"
    render json: { error: 'キャンセル処理に失敗しました' }, status: :internal_server_error
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
      cancelled: order.cancelled?,
      cancelled_at: order.cancelled_at,
      cancellation_reason: order.cancellation_reason,
      can_cancel: order.can_cancel?,
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
