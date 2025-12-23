# 月次売上レポート
json.year @year
json.month @month
json.total_orders @orders.count
json.total_amount @orders.sum(:total_amount)
json.daily_breakdown @daily_breakdown
