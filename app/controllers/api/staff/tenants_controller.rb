class Api::Staff::TenantsController < Api::Staff::BaseController
  before_action :set_tenant, only: [:show, :update]

  def index
    @tenants = Tenant.includes(:subscription, :tenant_users)
                     .order(created_at: :desc)
                     .page(params[:page])
  end

  def show
  end

  def create
    @tenant = Tenant.new(tenant_params)

    if @tenant.save
      create_default_subscription(@tenant)
      render :show, status: :created
    else
      render json: { errors: @tenant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @tenant.update(tenant_params)
      render :show
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
end
