class Api::Tenant::SubscriptionsController < Api::Tenant::BaseController
  def show
    @subscription = current_tenant.subscription

    unless @subscription
      render json: { error: 'サブスクリプション情報が見つかりません' }, status: :not_found
    end
  end
end
