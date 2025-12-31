class Api::Store::PaymentsController < Api::Store::BaseController
  include Loggable

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
                              .includes(table_session: { orders: :order_items })
                              .order(created_at: :desc)

    render json: @payments.map { |payment| PaymentSerializer.new(payment).as_json }
  end

  # GET /api/store/payments/:id
  def show
    render json: PaymentSerializer.new(@payment).as_json
  end

  # POST /api/store/payments
  def create
    @table_session = current_tenant.table_sessions.find(payment_params[:table_session_id])

    unless @table_session.active?
      return render json: { error: '会計できない状態です（セッションが終了しています）' }, status: :unprocessable_entity
    end

    # テーブルセッションの合計金額を計算
    total = @table_session.total_amount

    @payment = current_tenant.payments.new(
      table_session: @table_session,
      payment_method: payment_params[:payment_method],
      amount: total,
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
      # 決済完了を記録
      log_business_event(:payment_completed, @payment, metadata: {
        payment_method: @payment.payment_method,
        amount: @payment.amount,
        table_session_id: @payment.table_session_id
      })

      render json: PaymentSerializer.new(@payment).as_json
    else
      # 決済失敗を記録
      log_business_event(:payment_failed, @payment, metadata: {
        payment_method: @payment.payment_method,
        amount: @payment.amount,
        reason: @payment.errors.full_messages.join(', ')
      })

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
    params.require(:payment).permit(:table_session_id, :payment_method, :notes)
  end
end
