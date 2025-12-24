class Api::Store::MenuItemsController < Api::Store::BaseController
  def index
    @menu_items = current_tenant.menu_items
                                .available
                                .order(category: :asc, name: :asc)

    render json: @menu_items.map { |item| MenuItemSerializer.new(item).as_json }
  end

  def show
    @menu_item = current_tenant.menu_items.available.find(params[:id])
    render json: MenuItemSerializer.new(@menu_item).as_json
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'メニュー項目が見つかりません' }, status: :not_found
  end
end
