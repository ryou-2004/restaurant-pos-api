class Api::Tenant::AuthenticationController < ActionController::API
  include Loggable

  def login
    @tenant_user = TenantUser.find_by(email: params[:email])

    if @tenant_user&.authenticate(params[:password])
      # ログイン成功を記録
      log_authentication(:login, @tenant_user, success: true, metadata: { email: params[:email] })

      token = JsonWebToken.encode(tenant_user_id: @tenant_user.id, user_type: 'tenant')
      render json: {
        token: token,
        user: TenantUserSerializer.new(@tenant_user, include_subscription: true, user_type: 'tenant').as_json
      }, status: :ok
    else
      # ログイン失敗を記録
      log_authentication(:login_failed, @tenant_user, success: false, metadata: {
        email: params[:email],
        reason: 'invalid_credentials'
      })

      render json: { error: 'メールアドレスまたはパスワードが正しくありません' }, status: :unauthorized
    end
  end

  def me
    @tenant_user = current_tenant_user

    if @tenant_user
      render json: {
        user: TenantUserSerializer.new(@tenant_user, include_subscription: true, user_type: 'tenant').as_json
      }, status: :ok
    else
      render json: { error: 'ユーザーが見つかりません' }, status: :unauthorized
    end
  end

  def logout
    @tenant_user = current_tenant_user

    if @tenant_user
      # ログアウトを記録
      log_authentication(:logout, @tenant_user, success: true)
    end

    render json: { message: 'ログアウトしました' }, status: :ok
  end

  private

  def current_tenant_user
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    decoded = JsonWebToken.decode(token)

    if decoded && decoded[:user_type] == 'tenant'
      TenantUser.find_by(id: decoded[:tenant_user_id])
    end
  rescue
    nil
  end
end
