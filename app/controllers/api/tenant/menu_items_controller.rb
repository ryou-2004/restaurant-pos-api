class Api::Tenant::MenuItemsController < Api::Tenant::BaseController
  before_action :require_manager_or_above, except: [:index, :show]
  before_action :set_menu_item, only: [:show, :update, :destroy]

  def index
    @menu_items = current_tenant.menu_items
                                .order(category: :asc, name: :asc)
                                .page(params[:page])

    render json: @menu_items.map { |item| menu_item_response(item) }
  end

  def show
    render json: menu_item_response(@menu_item)
  end

  def create
    @menu_item = current_tenant.menu_items.new(menu_item_params)

    if @menu_item.save
      render json: menu_item_response(@menu_item), status: :created
    else
      render json: { errors: @menu_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @menu_item.update(menu_item_params)
      render json: menu_item_response(@menu_item)
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

  def menu_item_response(menu_item)
    {
      id: menu_item.id,
      name: menu_item.name,
      price: menu_item.price,
      category: menu_item.category,
      available: menu_item.available,
      created_at: menu_item.created_at,
      updated_at: menu_item.updated_at
    }
  end
end
