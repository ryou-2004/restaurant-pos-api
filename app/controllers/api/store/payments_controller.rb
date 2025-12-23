class Api::Store::PaymentsController < Api::Store::BaseController
  # ========================================
  # before_action定義
  # ========================================
  before_action :set_payment, only: [:show, :complete]

  # ========================================
  # CRUD操作
  # ========================================

  # GET /api/store/payments
  def index
    @payments = current_tenant.payments
                              .includes(order: :order_items)
                              .order(created_at: :desc)

    render json: @payments.map { |payment| PaymentSerializer.new(payment).as_json }
  end

  # GET /api/store/payments/:id
  def show
    render json: PaymentSerializer.new(@payment).as_json
  end

  # POST /api/store/payments
  def create
    @order = current_tenant.orders.find(payment_params[:order_id])

    unless @order.can_pay?
      return render json: { error: '会計できない状態です' }, status: :unprocessable_entity
    end

    @payment = current_tenant.payments.new(
      order: @order,
      payment_method: payment_params[:payment_method],
      amount: @order.total_amount,
      status: :pending
    )

    if @payment.save
      render json: PaymentSerializer.new(@payment).as_json, status: :created
    else
      render json: { errors: @payment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # ========================================
  # カスタムアクション
  # ========================================

  # PATCH /api/store/payments/:id/complete
  def complete
    unless @payment.pending?
      return render json: { error: '完了できない状態です' }, status: :unprocessable_entity
    end

    if @payment.mark_as_completed!
      render json: PaymentSerializer.new(@payment).as_json
    else
      render json: { errors: @payment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # ========================================
  # プライベートメソッド
  # ========================================

  def set_payment
    @payment = current_tenant.payments.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: '支払いが見つかりません' }, status: :not_found
  end

  def payment_params
    params.require(:payment).permit(:order_id, :payment_method, :notes)
  end
end
