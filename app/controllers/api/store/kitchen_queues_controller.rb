class Api::Store::KitchenQueuesController < Api::Store::BaseController
  # ========================================
  # before_action定義
  # ========================================
  before_action :set_kitchen_queue, only: [:show, :update, :start, :complete]

  # ========================================
  # CRUD操作
  # ========================================

  # GET /api/store/kitchen_queues
  def index
    @kitchen_queues = current_tenant.kitchen_queues
                                    .includes(order: { order_items: :menu_item })
                                    .active
                                    .by_priority

    render json: @kitchen_queues.map { |queue| KitchenQueueSerializer.new(queue).as_json }
  end

  # GET /api/store/kitchen_queues/:id
  def show
    render json: KitchenQueueSerializer.new(@kitchen_queue).as_json
  end

  # PATCH /api/store/kitchen_queues/:id
  def update
    if @kitchen_queue.update(kitchen_queue_params)
      render json: KitchenQueueSerializer.new(@kitchen_queue).as_json
    else
      render json: { errors: @kitchen_queue.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # ========================================
  # カスタムアクション
  # ========================================

  # PATCH /api/store/kitchen_queues/:id/start
  def start
    unless @kitchen_queue.waiting?
      return render json: { error: '調理開始できない状態です' }, status: :unprocessable_entity
    end

    if @kitchen_queue.start_cooking!
      render json: KitchenQueueSerializer.new(@kitchen_queue).as_json
    else
      render json: { errors: @kitchen_queue.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/store/kitchen_queues/:id/complete
  def complete
    unless @kitchen_queue.in_progress?
      return render json: { error: '完了できない状態です' }, status: :unprocessable_entity
    end

    if @kitchen_queue.mark_as_completed!
      render json: KitchenQueueSerializer.new(@kitchen_queue).as_json
    else
      render json: { errors: @kitchen_queue.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # ========================================
  # プライベートメソッド
  # ========================================

  def set_kitchen_queue
    @kitchen_queue = current_tenant.kitchen_queues.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'キューが見つかりません' }, status: :not_found
  end

  def kitchen_queue_params
    params.require(:kitchen_queue).permit(:priority, :notes)
  end
end
