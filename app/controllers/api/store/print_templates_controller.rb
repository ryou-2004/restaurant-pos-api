module Api
  module Store
    class PrintTemplatesController < ApplicationController
      before_action :authenticate_tenant_user!
      before_action :set_store
      before_action :set_print_template, only: [:show, :update]

      # GET /api/store/print_templates
      def index
        # 店舗固有 + テナント共通のテンプレート
        @templates = PrintTemplate.where(tenant: current_tenant)
                                   .where('store_id IS NULL OR store_id = ?', @store.id)
                                   .order(created_at: :desc)

        render json: @templates.map { |template|
          {
            id: template.id,
            name: template.name,
            template_type: template.template_type,
            is_active: template.is_active,
            settings: template.settings,
            scope: template.store_id.present? ? 'store' : 'tenant',
            created_at: template.created_at,
            updated_at: template.updated_at
          }
        }
      end

      # GET /api/store/print_templates/:id
      def show
        render json: {
          id: @template.id,
          name: @template.name,
          template_type: @template.template_type,
          content: @template.content,
          is_active: @template.is_active,
          settings: @template.settings,
          scope: @template.store_id.present? ? 'store' : 'tenant',
          created_at: @template.created_at,
          updated_at: @template.updated_at
        }
      end

      # PATCH /api/store/print_templates/:id
      def update
        # テナント共通テンプレートは編集不可（店舗固有のみ）
        if @template.store_id.nil?
          return render json: { error: 'テナント共通テンプレートは編集できません' },
                        status: :forbidden
        end

        if @template.update(template_params)
          render json: {
            id: @template.id,
            name: @template.name,
            template_type: @template.template_type,
            content: @template.content,
            is_active: @template.is_active,
            settings: @template.settings,
            scope: 'store',
            created_at: @template.created_at,
            updated_at: @template.updated_at
          }
        else
          render json: { errors: @template.errors.full_messages },
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

      def set_print_template
        @template = PrintTemplate.where(tenant: current_tenant)
                                  .where('store_id IS NULL OR store_id = ?', @store.id)
                                  .find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'テンプレートが見つかりません' }, status: :not_found
      end

      def template_params
        params.require(:print_template).permit(:name, :content, :is_active, settings: {})
      end
    end
  end
end
