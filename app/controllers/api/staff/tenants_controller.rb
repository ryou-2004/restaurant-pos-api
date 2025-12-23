class Api::Staff::TenantsController < Api::Staff::BaseController
  before_action :set_tenant, only: [:show, :update]

  def index
    @tenants = Tenant.includes(:subscription, :tenant_users)
                     .order(created_at: :desc)
                     .page(params[:page])

    render json: @tenants.map { |tenant| tenant_response(tenant) }
  end

  def show
    render json: tenant_response(@tenant)
  end

  def create
    @tenant = Tenant.new(tenant_params)

    if @tenant.save
      create_default_subscription(@tenant)
      render json: tenant_response(@tenant), status: :created
    else
      render json: { errors: @tenant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @tenant.update(tenant_params)
      render json: tenant_response(@tenant)
    else
      render json: { errors: @tenant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_tenant
    @tenant = Tenant.includes(:subscription, :tenant_users).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'テナントが見つかりません' }, status: :not_found
  end

  def tenant_params
    params.require(:tenant).permit(:name, :subdomain)
  end

  def create_default_subscription(tenant)
    tenant.create_subscription(
      plan: :basic,
      max_stores: 1,
      realtime_enabled: false,
      polling_enabled: false,
      expires_at: 1.year.from_now
    )
  end

  def tenant_response(tenant)
    {
      id: tenant.id,
      name: tenant.name,
      subdomain: tenant.subdomain,
      created_at: tenant.created_at,
      subscription: subscription_response(tenant.subscription),
      user_count: tenant.tenant_users.size
    }
  end

  def subscription_response(subscription)
    return nil unless subscription

    {
      id: subscription.id,
      plan: subscription.plan,
      realtime_enabled: subscription.realtime_enabled,
      polling_enabled: subscription.polling_enabled,
      max_stores: subscription.max_stores,
      expires_at: subscription.expires_at,
      active: subscription.active?
    }
  end
end
