module Api
  module Store
    class ActivityLogsController < BaseController
      # GET /api/store/activity_logs
      def index
        @logs = ActivityLog.by_store(@current_store_id).recent

        # フィルタリング
        @logs = @logs.by_action_type(params[:action_type]) if params[:action_type].present?

        if params[:start_date].present? && params[:end_date].present?
          @logs = @logs.by_date_range(Date.parse(params[:start_date]), Date.parse(params[:end_date]))
        end

        # ページネーション
        @logs = @logs.page(params[:page]).per(50)

        render json: ActivityLogSerializer.serialize_collection(@logs)
      end

      # GET /api/store/activity_logs/:id
      def show
        @log = ActivityLog.by_store(@current_store_id).find(params[:id])
        render json: ActivityLogDetailSerializer.new(@log).as_json
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'ログが見つかりません' }, status: :not_found
      end
    end
  end
end
