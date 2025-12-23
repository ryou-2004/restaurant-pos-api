class Api::Tenant::ReportsController < Api::Tenant::BaseController
  before_action :require_manager_or_above

  def index
    render :index
  end

  def daily
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    @orders = current_tenant.orders
                            .where('created_at >= ? AND created_at < ?', @date.beginning_of_day, @date.end_of_day)
                            .where(status: :paid)

    render :daily
  end

  def monthly
    @year = params[:year]&.to_i || Date.current.year
    @month = params[:month]&.to_i || Date.current.month
    start_date = Date.new(@year, @month, 1).beginning_of_day
    end_date = start_date.end_of_month.end_of_day

    @orders = current_tenant.orders
                            .where('created_at >= ? AND created_at <= ?', start_date, end_date)
                            .where(status: :paid)

    @daily_breakdown = build_daily_breakdown(@orders, start_date, end_date)

    render :monthly
  end

  def by_menu_item
    start_date = params[:start_date] ? Date.parse(params[:start_date]).beginning_of_day : 1.month.ago
    end_date = params[:end_date] ? Date.parse(params[:end_date]).end_of_day : Time.current

    order_items = OrderItem.joins(:order)
                           .where(orders: { tenant_id: current_tenant.id, status: :paid })
                           .where('orders.created_at >= ? AND orders.created_at <= ?', start_date, end_date)
                           .group(:menu_item_id)
                           .select('menu_item_id, SUM(quantity) as total_quantity, SUM(unit_price * quantity) as total_sales')

    @menu_item_sales = order_items.map { |item| build_menu_item_sales(item) }

    render :by_menu_item
  end

  private

  def build_daily_breakdown(orders, start_date, end_date)
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

  def build_menu_item_sales(item)
    menu_item = MenuItem.find(item.menu_item_id)
    {
      menu_item_id: item.menu_item_id,
      menu_item_name: menu_item.name,
      total_quantity: item.total_quantity,
      total_sales: item.total_sales
    }
  end
end
