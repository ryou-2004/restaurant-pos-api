class Api::Store::AuthenticationController < ActionController::API
  def login
    @user = TenantUser.find_by(email: params[:email])

    if @user&.authenticate(params[:password])
      @token = JsonWebToken.encode(user_id: @user.id, tenant_id: @user.tenant_id, user_type: 'store')
      render :login, status: :ok
    else
      render json: { error: 'メールアドレスまたはパスワードが正しくありません' }, status: :unauthorized
    end
  end

  def me
    @tenant_user = current_tenant_user

    if @tenant_user
      render :me, status: :ok
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

    if decoded && decoded[:user_type] == 'store'
      TenantUser.find_by(id: decoded[:user_id])
    end
  rescue
    nil
  end
end
