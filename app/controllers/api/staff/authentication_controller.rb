class Api::Staff::AuthenticationController < ActionController::API
  def login
    @staff_user = StaffUser.find_by(email: params[:email])

    if @staff_user&.authenticate(params[:password])
      @token = JsonWebToken.encode(staff_user_id: @staff_user.id, user_type: 'staff')
      render :login, status: :ok
    else
      render json: { error: 'メールアドレスまたはパスワードが正しくありません' }, status: :unauthorized
    end
  end

  def me
    @staff_user = current_staff_user

    if @staff_user
      render :me, status: :ok
    else
      render json: { error: 'ユーザーが見つかりません' }, status: :unauthorized
    end
  end

  def logout
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
