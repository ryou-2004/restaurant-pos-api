json.array! @menu_items do |menu_item|
  json.partial! 'api/store/menu_items/menu_item', menu_item: menu_item
end
