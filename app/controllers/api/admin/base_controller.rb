module Api::Admin
  class BaseController < ApplicationController
    before_action :require_manager_or_higher

    private

    def require_manager_or_higher
      unless current_user&.manager? || current_user&.admin?
        render json: { error: 'マネージャー権限が必要です' }, status: :forbidden
      end
    end
  end
end
