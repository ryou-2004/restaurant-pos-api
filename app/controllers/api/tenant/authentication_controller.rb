class Api::Tenant::AuthenticationController < ActionController::API
    def login
      user = TenantUser.find_by(email: params[:email])

      if user&.authenticate(params[:password])
        token = JsonWebToken.encode(user_id: user.id, tenant_id: user.tenant_id, user_type: 'tenant')

        render json: {
          token: token,
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            user_type: 'tenant'
          },
          tenant: {
            id: user.tenant.id,
            name: user.tenant.name,
            subdomain: user.tenant.subdomain,
            subscription: {
              plan: user.tenant.subscription.plan,
              realtime_enabled: user.tenant.subscription.realtime_enabled,
              polling_enabled: user.tenant.subscription.polling_enabled,
              max_stores: user.tenant.subscription.max_stores
            }
          }
        }, status: :ok
      else
        render json: { error: 'メールアドレスまたはパスワードが正しくありません' }, status: :unauthorized
      end
    end

    def me
      tenant_user = current_tenant_user

      if tenant_user
        render json: {
          user: {
            id: tenant_user.id,
            name: tenant_user.name,
            email: tenant_user.email,
            role: tenant_user.role,
            user_type: 'tenant'
          },
          tenant: {
            id: tenant_user.tenant.id,
            name: tenant_user.tenant.name,
            subdomain: tenant_user.tenant.subdomain,
            subscription: {
              plan: tenant_user.tenant.subscription.plan,
              realtime_enabled: tenant_user.tenant.subscription.realtime_enabled,
              polling_enabled: tenant_user.tenant.subscription.polling_enabled,
              max_stores: tenant_user.tenant.subscription.max_stores
            }
          }
        }, status: :ok
      else
        render json: { error: 'ユーザーが見つかりません' }, status: :unauthorized
      end
    end

    def logout
      render json: { message: 'ログアウトしました' }, status: :ok
    end

    private

    def current_tenant_user
      header = request.headers['Authorization']
      token = header.split(' ').last if header
      decoded = JsonWebToken.decode(token)

      if decoded && decoded[:user_type] == 'tenant'
        TenantUser.find_by(id: decoded[:user_id])
      end
    rescue
      nil
    end
end
