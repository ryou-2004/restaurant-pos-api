module Api
  class AuthenticationController < ApplicationController
    skip_before_action :authenticate_request, only: [:login]

    def login
      user = TenantUser.find_by(email: params[:email])

      if user&.authenticate(params[:password])
        token = JsonWebToken.encode(user_id: user.id, tenant_id: user.tenant_id)

        render json: {
          token: token,
          user: user_response(user),
          tenant: tenant_response(user.tenant)
        }, status: :ok
      else
        render json: { error: 'メールアドレスまたはパスワードが正しくありません' }, status: :unauthorized
      end
    end

    def me
      render json: {
        user: user_response(current_user),
        tenant: tenant_response(current_user.tenant)
      }, status: :ok
    end

    def logout
      render json: { message: 'ログアウトしました' }, status: :ok
    end

    private

    def user_response(user)
      {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role
      }
    end

    def tenant_response(tenant)
      {
        id: tenant.id,
        name: tenant.name,
        subdomain: tenant.subdomain,
        subscription: {
          plan: tenant.subscription.plan,
          realtime_enabled: tenant.subscription.realtime_enabled,
          polling_enabled: tenant.subscription.polling_enabled,
          max_stores: tenant.subscription.max_stores
        }
      }
    end
  end
end
