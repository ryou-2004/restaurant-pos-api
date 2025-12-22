module Api::Staff
  class BaseController < ActionController::API
    before_action :authenticate_staff_user
    before_action :set_current_staff_user

    attr_reader :current_staff_user

    private

    def authenticate_staff_user
      header = request.headers['Authorization']
      token = header.split(' ').last if header
      decoded = JsonWebToken.decode(token)

      if decoded && decoded[:user_type] == 'staff'
        @current_staff_user = StaffUser.find_by(id: decoded[:staff_user_id])

        unless @current_staff_user
          render json: { error: 'スタッフが見つかりません' }, status: :unauthorized
        end
      else
        render json: { error: '認証に失敗しました' }, status: :unauthorized
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'スタッフが見つかりません' }, status: :unauthorized
    end

    def set_current_staff_user
      Current.staff_user = @current_staff_user if @current_staff_user
    end

    def require_system_admin
      unless current_staff_user&.system_admin?
        render json: { error: 'システム管理者権限が必要です' }, status: :forbidden
      end
    end
  end
end
