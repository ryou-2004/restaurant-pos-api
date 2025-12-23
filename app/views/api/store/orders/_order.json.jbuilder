json.id order.id
json.order_number order.order_number
json.status order.status
json.table_id order.table_id
json.total_amount order.total_amount
json.created_at order.created_at
json.updated_at order.updated_at

json.order_items order.order_items do |item|
  json.id item.id
  json.menu_item_id item.menu_item_id
  json.quantity item.quantity
  json.unit_price item.unit_price
  json.notes item.notes
end
