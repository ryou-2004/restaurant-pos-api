class Api::Tenant::SubscriptionsController < Api::Tenant::BaseController
  def show
    subscription = current_tenant.subscription

    if subscription
      render json: subscription_response(subscription)
    else
      render json: { error: 'サブスクリプション情報が見つかりません' }, status: :not_found
    end
  end

  private

  def subscription_response(subscription)
    {
      id: subscription.id,
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
