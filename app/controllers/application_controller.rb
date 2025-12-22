class ApplicationController < ActionController::API
  before_action :authenticate_request
  before_action :set_current_tenant

  attr_reader :current_user

  private

  def authenticate_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    decoded = JsonWebToken.decode(token)

    if decoded
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
end
