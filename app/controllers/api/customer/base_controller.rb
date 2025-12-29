class Api::Customer::BaseController < ActionController::API
  before_action :authenticate_customer_session
  before_action :set_current_context

  attr_reader :current_table, :current_tenant, :current_store, :current_table_session

  private

  def authenticate_customer_session
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    decoded = JsonWebToken.decode(token)

    if decoded && decoded[:user_type] == 'customer'
      @table_id = decoded[:table_id]
      @table_session_id = decoded[:table_session_id]
      @tenant_id = decoded[:tenant_id]
      @store_id = decoded[:store_id]

      unless @table_id && @table_session_id && @tenant_id && @store_id
        render json: { error: 'セッション情報が不正です' }, status: :unauthorized
        return
      end
    else
      render json: { error: '認証に失敗しました' }, status: :unauthorized
    end
  rescue StandardError => e
    Rails.logger.error "Customer authentication error: #{e.message}"
    render json: { error: '認証に失敗しました' }, status: :unauthorized
  end

  def set_current_context
    return unless @table_id && @table_session_id && @tenant_id && @store_id

    @current_table = Table.find_by(id: @table_id, tenant_id: @tenant_id, store_id: @store_id)
    @current_table_session = TableSession.find_by(id: @table_session_id, tenant_id: @tenant_id, store_id: @store_id)
    @current_tenant = Tenant.find_by(id: @tenant_id)
    @current_store = Store.find_by(id: @store_id, tenant_id: @tenant_id)

    unless @current_table && @current_table_session && @current_tenant && @current_store
      render json: { error: 'テーブルセッションまたは店舗が見つかりません' }, status: :not_found
      return
    end

    # Set global context
    Current.tenant = @current_tenant
  end
end
