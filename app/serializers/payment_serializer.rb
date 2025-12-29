class PaymentSerializer
  def initialize(payment)
    @payment = payment
  end

  def as_json(options = {})
    {
      id: @payment.id,
      payment_method: @payment.payment_method,
      amount: @payment.amount,
      status: @payment.status,
      paid_at: @payment.paid_at,
      notes: @payment.notes,
      table_session: table_session_json,
      created_at: @payment.created_at,
      updated_at: @payment.updated_at
    }
  end

  private

  def table_session_json
    return nil unless @payment.table_session

    {
      id: @payment.table_session.id,
      table_id: @payment.table_session.table_id,
      party_size: @payment.table_session.party_size,
      order_count: @payment.table_session.order_count,
      total_amount: @payment.table_session.total_amount,
      duration_minutes: @payment.table_session.duration_in_minutes,
      status: @payment.table_session.status
    }
  end
end
