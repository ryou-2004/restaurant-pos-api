class Api::Staff::AuthenticationController < ActionController::API
  include Loggable

  def login
    @staff_user = StaffUser.find_by(email: params[:email])

    if @staff_user&.authenticate(params[:password])
      # ログイン成功を記録
      log_authentication(:login, @staff_user, success: true, metadata: { email: params[:email] })

      token = JsonWebToken.encode(staff_user_id: @staff_user.id, user_type: 'staff')
      render json: {
        token: token,
        user: StaffUserSerializer.new(@staff_user).as_json
      }, status: :ok
    else
      # ログイン失敗を記録
      log_authentication(:login_failed, @staff_user, success: false, metadata: {
        email: params[:email],
        reason: 'invalid_credentials'
      })

      render json: { error: 'メールアドレスまたはパスワードが正しくありません' }, status: :unauthorized
    end
  end

  def me
    @staff_user = current_staff_user

    if @staff_user
      render json: {
        user: StaffUserSerializer.new(@staff_user).as_json
      }, status: :ok
    else
      render json: { error: 'ユーザーが見つかりません' }, status: :unauthorized
    end
  end

  def logout
    @staff_user = current_staff_user

    if @staff_user
      # ログアウトを記録
      log_authentication(:logout, @staff_user, success: true)
    end

    render json: { message: 'ログアウトしました' }, status: :ok
  end

  private

  def current_staff_user
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    decoded = JsonWebToken.decode(token)

    if decoded && decoded[:user_type] == 'staff'
      StaffUser.find_by(id: decoded[:staff_user_id])
    end
  rescue
    nil
  end
end
