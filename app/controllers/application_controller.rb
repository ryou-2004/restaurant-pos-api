class ApplicationController < ActionController::API
  before_action :authenticate_request
  before_action :set_current_tenant

  # 現在ログイン中のユーザーを取得
  attr_reader :current_user

  private

  def authenticate_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    decoded = JsonWebToken.decode(token)

    if decoded
      @current_user = User.find_by(id: decoded[:user_id])

      unless @current_user
        render json: { error: 'ユーザーが見つかりません' }, status: :unauthorized
      end
    else
      render json: { error: '認証に失敗しました' }, status: :unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'ユーザーが見つかりません' }, status: :unauthorized
  end

  # 認証をスキップするコントローラーで使用
  def skip_authentication
    # サブクラスでskip_before_action :authenticate_requestを呼ぶ
  end

  def set_current_tenant
    return unless @current_user

    Current.tenant = @current_user.tenant
    Current.user = @current_user
  end

  # 管理者権限チェック
  def require_admin
    unless current_user&.admin?
      render json: { error: '管理者権限が必要です' }, status: :forbidden
    end
  end

  # マネージャー以上の権限チェック
  def require_manager
    unless current_user&.manager_or_admin?
      render json: { error: 'マネージャー権限が必要です' }, status: :forbidden
    end
  end
end
