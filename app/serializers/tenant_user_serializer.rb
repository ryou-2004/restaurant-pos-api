# TenantUser認証レスポンス用シリアライザー
# Tenant管理画面とStore POS画面の両方で使用
class TenantUserSerializer
  def initialize(tenant_user, options = {})
    @tenant_user = tenant_user
    @include_subscription = options[:include_subscription] || false
    @user_type = options[:user_type] || 'tenant'
  end

  def as_json(options = {})
    {
      id: @tenant_user.id,
      name: @tenant_user.name,
      email: @tenant_user.email,
      role: @tenant_user.role,
      user_type: @user_type,
      tenant: tenant_json
    }
  end

  private

  def tenant_json
    base_tenant = {
      id: @tenant_user.tenant.id,
      name: @tenant_user.tenant.name,
      subdomain: @tenant_user.tenant.subdomain
    }

    # Tenant管理画面ログイン時はサブスクリプション情報を含める
    if @include_subscription
      base_tenant[:subscription] = subscription_json
    end

    base_tenant
  end

  def subscription_json
    subscription = @tenant_user.tenant.subscription
    {
      plan: subscription.plan,
      realtime_enabled: subscription.realtime_enabled,
      polling_enabled: subscription.polling_enabled,
      max_stores: subscription.max_stores
    }
  end
end
