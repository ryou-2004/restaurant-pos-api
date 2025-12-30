module Api
  module Store
    class PrintLogsController < ApplicationController
      before_action :authenticate_tenant_user!
      before_action :set_store

      # GET /api/store/print_logs
      def index
        @logs = PrintLog.where(store: @store)
                        .includes(:order, :print_template)
                        .recent
                        .limit(params[:limit] || 100)

        render json: @logs.map { |log|
          {
            id: log.id,
            order_id: log.order_id,
            order_number: log.order&.order_number,
            template_name: log.print_template&.name,
            status: log.status,
            error_message: log.error_message,
            printer_name: log.printer_name,
            printed_at: log.printed_at,
            created_at: log.created_at
          }
        }
      end

      # GET /api/store/print_logs/:id
      def show
        @log = PrintLog.where(store: @store)
                       .includes(:order, :print_template)
                       .find(params[:id])

        render json: {
          id: @log.id,
          order: {
            id: @log.order.id,
            order_number: @log.order.order_number,
            table_id: @log.order.table_id,
            status: @log.order.status
          },
          print_template: @log.print_template ? {
            id: @log.print_template.id,
            name: @log.print_template.name,
            template_type: @log.print_template.template_type
          } : nil,
          status: @log.status,
          error_message: @log.error_message,
          printer_name: @log.printer_name,
          printed_at: @log.printed_at,
          created_at: @log.created_at
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: '印刷ログが見つかりません' }, status: :not_found
      end

      # POST /api/store/print_logs
      def create
        @log = PrintLog.new(print_log_params)
        @log.tenant = current_tenant
        @log.store = @store
        @log.printed_at ||= Time.current

        if @log.save
          render json: { id: @log.id, status: @log.status }, status: :created
        else
          render json: { errors: @log.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      private

      def set_store
        @store = current_tenant.stores.find_by(id: params[:store_id] || session[:store_id])

        unless @store
          render json: { error: '店舗が見つかりません' }, status: :not_found
        end
      end

      def print_log_params
        params.require(:print_log).permit(
          :order_id,
          :print_template_id,
          :status,
          :error_message,
          :printer_name,
          :printed_at
        )
      end
    end
  end
end
