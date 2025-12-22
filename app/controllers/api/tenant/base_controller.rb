module Api::Tenant
  class BaseController < ActionController::API
    before_action :authenticate_tenant_user
    before_action :set_current_tenant
    before_action :require_tenant_dashboard_access

    attr_reader :current_user

    private

    def authenticate_tenant_user
      header = request.headers['Authorization']
      token = header.split(' ').last if header
      decoded = JsonWebToken.decode(token)

      if decoded && decoded[:user_type] == 'tenant'
        @current_user = TenantUser.find_by(id: decoded[:user_id])

        unless @current_user
          render json: { error: 'ユーザーが見つかりません' }, status: :unauthorized
        end
      else
        render json: { error: '認証に失敗しました' }, status: :unauthorized
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'ユーザーが見つかりません' }, status: :unauthorized
    end

    def set_current_tenant
      return unless @current_user

      Current.tenant = @current_user.tenant
      Current.user = @current_user
    end

    def require_tenant_dashboard_access
      unless current_user&.can_access_tenant_dashboard?
        render json: { error: 'テナント管理画面へのアクセス権限がありません' }, status: :forbidden
      end
    end

    def require_owner
      unless current_user&.owner?
        render json: { error: 'オーナー権限が必要です' }, status: :forbidden
      end
    end
  end
end
