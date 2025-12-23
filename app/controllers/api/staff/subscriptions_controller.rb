class Api::Staff::SubscriptionsController < Api::Staff::BaseController
  before_action :set_subscription, only: [:show, :update]

  def index
    @subscriptions = Subscription.includes(:tenant)
                                 .order(created_at: :desc)
                                 .page(params[:page])

    render json: @subscriptions.map { |subscription| subscription_response(subscription) }
  end

  def show
    render json: subscription_response(@subscription)
  end

  def update
    if @subscription.update(subscription_params)
      render json: subscription_response(@subscription)
    else
      render json: { errors: @subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_subscription
    @subscription = Subscription.includes(:tenant).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'サブスクリプションが見つかりません' }, status: :not_found
  end

  def subscription_params
    params.require(:subscription).permit(:plan, :max_stores, :realtime_enabled, :polling_enabled, :expires_at)
  end

  def subscription_response(subscription)
    {
      id: subscription.id,
      tenant: {
        id: subscription.tenant.id,
        name: subscription.tenant.name,
        subdomain: subscription.tenant.subdomain
      },
      plan: subscription.plan,
      realtime_enabled: subscription.realtime_enabled,
      polling_enabled: subscription.polling_enabled,
      max_stores: subscription.max_stores,
      expires_at: subscription.expires_at,
      active: subscription.active?,
      created_at: subscription.created_at,
      updated_at: subscription.updated_at
    }
  end
end
