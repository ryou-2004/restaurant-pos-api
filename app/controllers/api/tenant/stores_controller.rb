module Api
  module Tenant
    class StoresController < Api::Tenant::BaseController
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
          render json: @store, status: :created
        else
          render json: { errors: @store.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/tenant/stores/:id
      def update
        if @store.update(store_params)
          render json: @store
        else
          render json: { errors: @store.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/tenant/stores/:id
      def destroy
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
