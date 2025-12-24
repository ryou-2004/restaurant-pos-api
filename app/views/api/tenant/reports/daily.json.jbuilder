# 日次売上レポート
json.date @date
json.total_orders @orders.count
json.total_amount @orders.sum(:total_amount)
json.active_orders @active_orders

json.orders @orders do |order|
  json.id order.id
  json.order_number order.order_number
  json.total_amount order.total_amount
  json.created_at order.created_at
end
