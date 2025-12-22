module Api::Staff
  class BaseController < ApplicationController
    before_action :require_staff_or_higher

    private

    def require_staff_or_higher
      unless current_user&.staff? || current_user&.manager? || current_user&.admin?
        render json: { error: 'スタッフ権限が必要です' }, status: :forbidden
      end
    end
  end
end
