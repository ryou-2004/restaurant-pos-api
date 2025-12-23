# メニュー別売上レポート
json.array! @menu_item_sales do |item|
  json.menu_item_id item[:menu_item_id]
  json.menu_item_name item[:menu_item_name]
  json.total_quantity item[:total_quantity]
  json.total_sales item[:total_sales]
end
