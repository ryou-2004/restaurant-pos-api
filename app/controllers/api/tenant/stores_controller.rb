module Api
  module Tenant
    class StoresController < Api::Tenant::BaseController
      include Loggable

      before_action :require_manager_or_above
      before_action :set_store, only: [:show, :update, :destroy]

      # GET /api/tenant/stores
      def index
        @stores = current_tenant.stores.order(created_at: :desc)
        render json: @stores
      end

      # GET /api/tenant/stores/:id
      def show
        render json: @store
      end

      # POST /api/tenant/stores
      def create
        @store = current_tenant.stores.build(store_params)

        if @store.save
          # 店舗作成を記録
          log_activity(:create, resource: @store, metadata: {
            name: @store.name,
            address: @store.address
          })

          render json: @store, status: :created
        else
          render json: { errors: @store.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/tenant/stores/:id
      def update
        before_attrs = @store.attributes.slice('name', 'address', 'phone', 'active')

        if @store.update(store_params)
          after_attrs = @store.attributes.slice('name', 'address', 'phone', 'active')

          # 店舗更新を記録
          log_crud_action(:update, @store, before: before_attrs, after: after_attrs)

          render json: @store
        else
          render json: { errors: @store.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/tenant/stores/:id
      def destroy
        # 店舗削除を記録
        log_activity(:delete, resource: @store, metadata: {
          name: @store.name
        })

        @store.destroy
        head :no_content
      end

      private

      def set_store
        @store = current_tenant.stores.find(params[:id])
      end

      def store_params
        params.require(:store).permit(:name, :address, :phone, :active)
      end
    end
  end
end
