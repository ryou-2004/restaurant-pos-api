class Api::Store::StaffCallsController < Api::Store::BaseController
  include Loggable

  # GET /api/store/staff_calls
  def index
    @staff_calls = current_store.staff_calls
                                .includes(:table, :table_session)
                                .active
                                .recent

    render json: @staff_calls.map { |call| serialize_staff_call(call) }
  end

  # PATCH /api/store/staff_calls/:id/acknowledge
  def acknowledge
    @staff_call = current_store.staff_calls.find(params[:id])
    @staff_call.acknowledge!

    render json: serialize_staff_call(@staff_call)
  end

  # PATCH /api/store/staff_calls/:id/resolve
  def resolve
    @staff_call = current_store.staff_calls.find(params[:id])
    @staff_call.resolve!(current_user)

    # 対応完了ログ記録
    log_business_event(:staff_call_resolved, @staff_call, metadata: {
      table_number: @staff_call.table.number,
      call_type: @staff_call.call_type,
      waiting_minutes: @staff_call.waiting_minutes.to_i
    })

    render json: serialize_staff_call(@staff_call)
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
      resolved_at: call.resolved_at,
      resolved_by_name: call.resolved_by&.name
    }
  end
end
