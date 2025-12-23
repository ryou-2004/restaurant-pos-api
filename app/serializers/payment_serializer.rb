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
      order: order_json,
      created_at: @payment.created_at,
      updated_at: @payment.updated_at
    }
  end

  private

  def order_json
    return nil unless @payment.order

    {
      id: @payment.order.id,
      order_number: @payment.order.order_number,
      table_number: @payment.order.table_number,
      total_amount: @payment.order.total_amount,
      status: @payment.order.status
    }
  end
end
