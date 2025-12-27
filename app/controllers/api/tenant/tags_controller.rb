module Api
  module Tenant
    class TagsController < Api::Tenant::BaseController
      before_action :require_manager_or_above
      before_action :set_tag, only: [:show, :update, :destroy]

      # GET /api/tenant/tags
      def index
        @tags = current_tenant.tags.order(:name)
        render json: @tags
      end

      # GET /api/tenant/tags/:id
      def show
        render json: @tag
      end

      # POST /api/tenant/tags
      def create
        @tag = current_tenant.tags.build(tag_params)

        if @tag.save
          render json: @tag, status: :created
        else
          render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/tenant/tags/:id
      def update
        if @tag.update(tag_params)
          render json: @tag
        else
          render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/tenant/tags/:id
      def destroy
        @tag.destroy
        head :no_content
      end

      private

      def set_tag
        @tag = current_tenant.tags.find(params[:id])
      end

      def tag_params
        params.require(:tag).permit(:name)
      end
    end
  end
end
