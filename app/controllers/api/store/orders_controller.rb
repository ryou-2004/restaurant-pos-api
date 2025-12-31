class Api::Store::OrdersController < Api::Store::BaseController
  include Loggable

  # ========================================
  # before_action定義
  # ========================================
  before_action :set_order, only: [:show, :update, :start_cooking, :mark_as_ready, :deliver, :print_kitchen_ticket]

  # ========================================
  # CRUD操作
  # ========================================

  # GET /api/store/orders
  def index
    @orders = current_tenant.orders
                            .includes(:order_items => :menu_item)

    # status パラメータでフィルタリング
    @orders = @orders.where(status: params[:status]) if params[:status].present?

    @orders = @orders.order(created_at: :desc)

    render json: @orders.map { |order| OrderSerializer.new(order).as_json }
  end

  # GET /api/store/orders/:id
  def show
    render json: OrderSerializer.new(@order).as_json
  end

  # POST /api/store/orders
  def create
    service = OrderService.new(current_tenant)
    @order = service.create_order(order_params.to_h.deep_symbolize_keys)

    # 注文作成を記録
    log_business_event(:order_placed, @order, metadata: {
      order_number: @order.order_number,
      total_amount: @order.total_amount,
      item_count: @order.order_items.count,
      table_id: @order.table_id
    })

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

      # 調理開始を記録
      log_business_event(:order_cooking_started, @order, metadata: {
        order_number: @order.order_number
      })

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

      # 調理完了を記録
      log_business_event(:order_ready, @order, metadata: {
        order_number: @order.order_number
      })

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
      # 配膳完了を記録
      log_business_event(:order_delivered, @order, metadata: {
        order_number: @order.order_number
      })

      render json: OrderSerializer.new(@order).as_json
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /api/store/orders/:id/print_kitchen_ticket
  def print_kitchen_ticket
    # 印刷機能が有効かチェック
    unless current_tenant.subscription.printing_enabled?
      return render json: { error: 'プランで印刷機能が利用できません' }, status: :forbidden
    end

    store = @order.store
    print_service = PrintService.new(store)

    print_data = print_service.generate_kitchen_ticket(@order)

    # 印刷フラグを更新（最初の印刷時のみ）
    @order.update(needs_printing: true, printed_at: Time.current) if @order.printed_at.nil?

    render json: {
      html: print_data[:html],
      order_id: print_data[:order_id],
      template_id: print_data[:template_id]
    }
  rescue StandardError => e
    Rails.logger.error "印刷データ生成エラー: #{e.message}"
    render json: { error: '印刷データの生成に失敗しました' }, status: :internal_server_error
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
      :table_id,
      :notes,
      order_items_attributes: [:menu_item_id, :quantity, :notes]
    )
  end

  def update_kitchen_queue_status(order, status)
    order.kitchen_queue&.update(status: status)
  end
end
