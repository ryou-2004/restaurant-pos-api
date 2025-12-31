class Api::Customer::StaffCallsController < Api::Customer::BaseController
  include Loggable

  # POST /api/customer/staff_calls
  def create
    @staff_call = StaffCall.create!(
      tenant_id: current_tenant.id,
      store_id: current_table.store_id,
      table_id: current_table.id,
      table_session_id: current_table_session.id,
      call_type: params[:call_type] || 'general',
      notes: params[:notes],
      status: :pending
    )

    # 店員呼び出しログ記録
    log_business_event(:staff_called, @staff_call, metadata: {
      table_number: current_table.number,
      call_type: @staff_call.call_type,
      notes: @staff_call.notes
    })

    render json: serialize_staff_call(@staff_call), status: :created
  rescue StandardError => e
    Rails.logger.error "Staff call creation error: #{e.message}"
    render json: { error: '呼び出しに失敗しました' }, status: :internal_server_error
  end

  # GET /api/customer/staff_calls
  def index
    @staff_calls = current_table_session.staff_calls.recent

    render json: @staff_calls.map { |call| serialize_staff_call(call) }
  end

  private

  def serialize_staff_call(call)
    {
      id: call.id,
      table_id: call.table_id,
      table_number: call.table.number,
      call_type: call.call_type,
      status: call.status,
      notes: call.notes,
      waiting_minutes: call.waiting_minutes.to_i,
      created_at: call.created_at,
      resolved_at: call.resolved_at
    }
  end
end
