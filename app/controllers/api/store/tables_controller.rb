module Api
  module Store
    class TablesController < Api::Store::BaseController
      # GET /api/store/tables
      def index
        @tables = current_store.tables
                               .order(:number)

        render json: @tables.map { |table| serialize_table(table) }
      end

      # GET /api/store/tables/:id
      def show
        @table = current_store.tables.find(params[:id])
        render json: serialize_table(@table)
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'テーブルが見つかりません' }, status: :not_found
      end

      private

      def serialize_table(table)
        {
          id: table.id,
          number: table.number,
          capacity: table.capacity,
          status: table.status,
          qr_code: table.qr_code
        }
      end
    end
  end
end
