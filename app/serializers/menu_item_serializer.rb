# MenuItem API レスポンス用シリアライザー
class MenuItemSerializer
  def initialize(menu_item)
    @menu_item = menu_item
  end

  def as_json(options = {})
    {
      id: @menu_item.id,
      name: @menu_item.name,
      price: @menu_item.price,
      category: @menu_item.category,
      description: @menu_item.description,  # フロントエンドで表示される
      available: @menu_item.available,
      created_at: @menu_item.created_at,
      updated_at: @menu_item.updated_at
    }
  end
end
