class Api::Staff::SubscriptionsController < Api::Staff::BaseController
  before_action :set_subscription, only: [:show, :update]

  def index
    @subscriptions = Subscription.includes(:tenant)
                                 .order(created_at: :desc)
                                 .page(params[:page])
  end

  def show
  end

  def update
    if @subscription.update(subscription_params)
      render :show
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
end
