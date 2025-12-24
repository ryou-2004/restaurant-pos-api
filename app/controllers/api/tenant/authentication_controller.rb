class Api::Tenant::AuthenticationController < ActionController::API
  def login
    @tenant_user = TenantUser.find_by(email: params[:email])

    if @tenant_user&.authenticate(params[:password])
      token = JsonWebToken.encode(tenant_user_id: @tenant_user.id, user_type: 'tenant')
      render json: {
        token: token,
        user: TenantUserSerializer.new(@tenant_user, include_subscription: true, user_type: 'tenant').as_json
      }, status: :ok
    else
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
