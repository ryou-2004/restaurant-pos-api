class Api::Tenant::MenuItemsController < Api::Tenant::BaseController
  before_action :require_manager_or_above, except: [:index, :show]
  before_action :set_menu_item, only: [:show, :update, :destroy]

  def index
    @menu_items = current_tenant.menu_items
                                .order(category: :asc, name: :asc)
                                .page(params[:page])
  end

  def show
  end

  def create
    @menu_item = current_tenant.menu_items.new(menu_item_params)

    if @menu_item.save
      render :show, status: :created
    else
      render json: { errors: @menu_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @menu_item.update(menu_item_params)
      render :show
    else
      render json: { errors: @menu_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @menu_item.destroy
    head :no_content
  end

  private

  def set_menu_item
    @menu_item = current_tenant.menu_items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'メニュー項目が見つかりません' }, status: :not_found
  end

  def menu_item_params
    params.require(:menu_item).permit(:name, :price, :category, :available)
  end
end
