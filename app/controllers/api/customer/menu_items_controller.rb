class Api::Customer::MenuItemsController < Api::Customer::BaseController
  def index
    # 現在のテナントの利用可能なメニュー項目のみを返す
    @menu_items = current_tenant.menu_items
                                .where(available: true)
                                .order(:category, :name)

    render json: @menu_items.map { |item| serialize_menu_item(item) }
  end

  private

  def serialize_menu_item(item)
    {
      id: item.id,
      name: item.name,
      price: item.price,
      category: item.category,
      description: item.description,
      available: item.available,
      created_at: item.created_at,
      updated_at: item.updated_at
    }
  end
end
