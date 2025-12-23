class Api::Tenant::ReportsController < Api::Tenant::BaseController
  before_action :require_manager_or_above

  def index
    render json: {
      message: '売上レポート一覧（実装予定）'
    }
  end

  def daily
    date = params[:date] ? Date.parse(params[:date]) : Date.current
    orders = current_tenant.orders
                           .where('created_at >= ? AND created_at < ?', date.beginning_of_day, date.end_of_day)
                           .where(status: :paid)

    render json: {
      date: date,
      total_orders: orders.count,
      total_amount: orders.sum(:total_amount),
      orders: orders.map { |order| order_summary(order) }
    }
  end

  def monthly
    year = params[:year]&.to_i || Date.current.year
    month = params[:month]&.to_i || Date.current.month
    start_date = Date.new(year, month, 1).beginning_of_day
    end_date = start_date.end_of_month.end_of_day

    orders = current_tenant.orders
                           .where('created_at >= ? AND created_at <= ?', start_date, end_date)
                           .where(status: :paid)

    render json: {
      year: year,
      month: month,
      total_orders: orders.count,
      total_amount: orders.sum(:total_amount),
      daily_breakdown: daily_breakdown(orders, start_date, end_date)
    }
  end

  def by_menu_item
    start_date = params[:start_date] ? Date.parse(params[:start_date]).beginning_of_day : 1.month.ago
    end_date = params[:end_date] ? Date.parse(params[:end_date]).end_of_day : Time.current

    order_items = OrderItem.joins(:order)
                           .where(orders: { tenant_id: current_tenant.id, status: :paid })
                           .where('orders.created_at >= ? AND orders.created_at <= ?', start_date, end_date)
                           .group(:menu_item_id)
                           .select('menu_item_id, SUM(quantity) as total_quantity, SUM(unit_price * quantity) as total_sales')

    render json: order_items.map { |item| menu_item_sales(item) }
  end

  private

  def order_summary(order)
    {
      id: order.id,
      order_number: order.order_number,
      total_amount: order.total_amount,
      created_at: order.created_at
    }
  end

  def daily_breakdown(orders, start_date, end_date)
    breakdown = {}
    current_date = start_date.to_date

    while current_date <= end_date.to_date
      day_orders = orders.where('created_at >= ? AND created_at < ?', current_date.beginning_of_day, current_date.end_of_day)
      breakdown[current_date.to_s] = {
        total_orders: day_orders.count,
        total_amount: day_orders.sum(:total_amount)
      }
      current_date += 1.day
    end

    breakdown
  end

  def menu_item_sales(item)
    menu_item = MenuItem.find(item.menu_item_id)
    {
      menu_item_id: item.menu_item_id,
      menu_item_name: menu_item.name,
      total_quantity: item.total_quantity,
      total_sales: item.total_sales
    }
  end
end
