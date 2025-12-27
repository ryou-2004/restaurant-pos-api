module Api
  module Tenant
    class TablesController < Api::Tenant::BaseController
      before_action :require_manager_or_above
      before_action :set_table, only: [:show, :update, :destroy]

      # GET /api/tenant/tables
      def index
        @tables = current_tenant.tables
                                .includes(:store)
                                .order('stores.name, tables.number')

        render json: @tables.map { |table| serialize_table(table) }
      end

      # GET /api/tenant/tables/:id
      def show
        render json: serialize_table(@table)
      end

      # POST /api/tenant/tables
      def create
        @table = current_tenant.tables.build(table_params)

        if @table.save
          render json: serialize_table(@table), status: :created
        else
          render json: { errors: @table.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/tenant/tables/:id
      def update
        if @table.update(table_params)
          render json: serialize_table(@table)
        else
          render json: { errors: @table.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/tenant/tables/:id
      def destroy
        @table.destroy
        head :no_content
      end

      private

      def set_table
        @table = current_tenant.tables.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'テーブルが見つかりません' }, status: :not_found
      end

      def table_params
        params.require(:table).permit(:store_id, :number, :capacity, :status)
      end

      def serialize_table(table)
        {
          id: table.id,
          store_id: table.store_id,
          store_name: table.store.name,
          number: table.number,
          capacity: table.capacity,
          status: table.status,
          qr_code: table.qr_code,
          created_at: table.created_at,
          updated_at: table.updated_at
        }
      end
    end
  end
end
