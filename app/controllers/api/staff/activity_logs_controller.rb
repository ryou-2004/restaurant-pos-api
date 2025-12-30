module Api
  module Staff
    class ActivityLogsController < BaseController
      # GET /api/staff/activity_logs
      def index
        @logs = ActivityLog.all.recent

        # フィルタリング
        @logs = @logs.by_tenant(params[:tenant_id]) if params[:tenant_id].present?
        @logs = @logs.by_store(params[:store_id]) if params[:store_id].present?
        @logs = @logs.by_action_type(params[:action_type]) if params[:action_type].present?
        @logs = @logs.by_user_type(params[:user_type]) if params[:user_type].present?

        if params[:user_id].present? && params[:user_type].present?
          @logs = @logs.where(user_id: params[:user_id], user_type: params[:user_type])
        end

        if params[:start_date].present? && params[:end_date].present?
          @logs = @logs.by_date_range(Date.parse(params[:start_date]), Date.parse(params[:end_date]))
        end

        # ページネーション
        @logs = @logs.page(params[:page]).per(50)

        render json: ActivityLogSerializer.serialize_collection(@logs)
      end

      # GET /api/staff/activity_logs/:id
      def show
        @log = ActivityLog.find(params[:id])
        render json: ActivityLogDetailSerializer.new(@log).as_json
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'ログが見つかりません' }, status: :not_found
      end

      # GET /api/staff/activity_logs/stats
      def stats
        @logs = ActivityLog.all

        # フィルタリング（statsにも適用）
        @logs = @logs.by_tenant(params[:tenant_id]) if params[:tenant_id].present?
        @logs = @logs.by_store(params[:store_id]) if params[:store_id].present?

        render json: ActivityLog.stats(@logs)
      end
    end
  end
end
