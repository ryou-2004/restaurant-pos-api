class Api::Tenant::BaseController < ActionController::API
  before_action :authenticate_tenant_user
  before_action :set_current_tenant

  attr_reader :current_tenant_user, :current_tenant

  private

  def authenticate_tenant_user
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    decoded = JsonWebToken.decode(token)

    if decoded && decoded[:user_type] == 'tenant'
      @current_tenant_user = TenantUser.includes(:tenant).find_by(id: decoded[:tenant_user_id])
      unless @current_tenant_user
        render json: { error: 'ユーザーが見つかりません' }, status: :unauthorized
      end
    else
      render json: { error: '認証に失敗しました' }, status: :unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'ユーザーが見つかりません' }, status: :unauthorized
  end

  def set_current_tenant
    @current_tenant = @current_tenant_user&.tenant
    Current.tenant = @current_tenant if @current_tenant
    Current.user = @current_tenant_user if @current_tenant_user
  end

  def require_owner
    unless current_tenant_user&.owner?
      render json: { error: 'オーナー権限が必要です' }, status: :forbidden
    end
  end

  def require_manager_or_above
    unless current_tenant_user&.can_access_tenant_dashboard?
      render json: { error: 'マネージャー以上の権限が必要です' }, status: :forbidden
    end
  end
end
