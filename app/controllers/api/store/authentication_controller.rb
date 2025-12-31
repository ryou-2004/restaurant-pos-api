class Api::Store::AuthenticationController < ActionController::API
  include Loggable

  def login
    @user = TenantUser.find_by(email: params[:email])

    if @user&.authenticate(params[:password])
      # ログイン成功を記録
      log_authentication(:login, @user, success: true, metadata: { email: params[:email] })

      token = JsonWebToken.encode(user_id: @user.id, tenant_id: @user.tenant_id, user_type: 'store')
      render json: {
        token: token,
        user: TenantUserSerializer.new(@user, include_subscription: false, user_type: 'store').as_json
      }, status: :ok
    else
      # ログイン失敗を記録
      log_authentication(:login_failed, @user, success: false, metadata: {
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
        user: TenantUserSerializer.new(@tenant_user, include_subscription: false, user_type: 'store').as_json
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

    if decoded && decoded[:user_type] == 'store'
      TenantUser.find_by(id: decoded[:user_id])
    end
  rescue
    nil
  end
end
