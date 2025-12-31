class Api::Customer::MenuItemsController < Api::Customer::BaseController
  include Loggable

  def index
    # 現在のテナントの利用可能なメニュー項目のみを返す（カテゴリー順でソート）
    @menu_items = current_tenant.menu_items
                                .where(available: true)
                                .ordered_by_category

    # メニュー一覧閲覧を記録
    log_activity(:page_accessed, metadata: {
      page: 'menu_items',
      action: 'index',
      item_count: @menu_items.count
    })

    render json: @menu_items.map { |item| serialize_menu_item(item) }
  end

  private

  def serialize_menu_item(item)
    {
      id: item.id,
      name: item.name,
      price: item.price,
      category: item.category,
      category_order: item.category_order,
      description: item.description,
      available: item.available,
      created_at: item.created_at,
      updated_at: item.updated_at
    }
  end
end
