class Api::Store::OrdersController < Api::Store::BaseController
  # ========================================
  # before_action定義
  # ========================================
  before_action :set_order, only: [:show, :update, :start_cooking, :mark_as_ready, :deliver]

  # ========================================
  # CRUD操作
  # ========================================

  # GET /api/store/orders
  def index
    @orders = current_tenant.orders
                            .includes(:order_items => :menu_item)
                            .order(created_at: :desc)

    render json: @orders.map { |order| OrderSerializer.new(order).as_json }
  end

  # GET /api/store/orders/:id
  def show
    render json: OrderSerializer.new(@order).as_json
  end

  # POST /api/store/orders
  def create
    service = OrderService.new(current_tenant)
    @order = service.create_order(order_params.to_h.symbolize_keys)

    render json: OrderSerializer.new(@order).as_json, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  # PATCH /api/store/orders/:id
  def update
    if @order.update(order_params)
      render json: OrderSerializer.new(@order).as_json
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # ========================================
  # カスタムアクション
  # ========================================

  # PATCH /api/store/orders/:id/start_cooking
  def start_cooking
    unless @order.can_start_cooking?
      return render json: { error: '調理開始できない状態です' }, status: :unprocessable_entity
    end

    if @order.update(status: :cooking)
      update_kitchen_queue_status(@order, :in_progress)
      render json: OrderSerializer.new(@order).as_json
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/store/orders/:id/mark_as_ready
  def mark_as_ready
    unless @order.can_mark_as_ready?
      return render json: { error: '調理完了にできない状態です' }, status: :unprocessable_entity
    end

    if @order.update(status: :ready)
      update_kitchen_queue_status(@order, :completed)
      render json: OrderSerializer.new(@order).as_json
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/store/orders/:id/deliver
  def deliver
    unless @order.can_deliver?
      return render json: { error: '配膳できない状態です' }, status: :unprocessable_entity
    end

    if @order.update(status: :delivered)
      render json: OrderSerializer.new(@order).as_json
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # ========================================
  # プライベートメソッド
  # ========================================

  def set_order
    @order = current_tenant.orders.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: '注文が見つかりません' }, status: :not_found
  end

  def order_params
    params.require(:order).permit(
      :table_number,
      :notes,
      order_items_attributes: [:menu_item_id, :quantity, :notes]
    )
  end

  def update_kitchen_queue_status(order, status)
    order.kitchen_queue&.update(status: status)
  end
end
