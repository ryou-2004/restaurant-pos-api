# ========================================
# ReportService
# ========================================
# 売上レポート生成サービス
# Payment.status == :completed を基準に集計

class ReportService
  def initialize(store)
    @store = store
    @tenant = store.tenant
  end

  # ========================================
  # 日別レポート
  # ========================================
  def daily_report(date)
    payments = completed_payments_for_date(date)
    sessions = completed_sessions_for_date(date)

    {
      date: date,
      total_sales: payments.sum(:amount),
      payment_count: payments.count,
      session_count: sessions.count,
      customer_count: sessions.sum(:party_size),
      average_bill: calculate_average_bill(payments, sessions),
      by_payment_method: payments.group(:payment_method).sum(:amount),
      top_menu_items: top_menu_items(date, limit: 10),
      hourly_breakdown: hourly_sales(date)
    }
  end

  # ========================================
  # 月別レポート
  # ========================================
  def monthly_report(year, month)
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    {
      year: year,
      month: month,
      total_sales: total_sales_for_range(start_date, end_date),
      total_payments: payment_count_for_range(start_date, end_date),
      daily_breakdown: daily_breakdown(start_date, end_date)
    }
  end

  private

  # ========================================
  # 完了済み支払いを取得
  # ========================================
  def completed_payments_for_date(date)
    @store.payments
          .completed
          .where('paid_at >= ? AND paid_at < ?',
                 date.beginning_of_day, date.end_of_day)
  end

  # ========================================
  # 完了済みセッションを取得
  # ========================================
  def completed_sessions_for_date(date)
    @store.table_sessions
          .completed
          .where('ended_at >= ? AND ended_at < ?',
                 date.beginning_of_day, date.end_of_day)
  end

  # ========================================
  # 平均客単価を計算
  # ========================================
  def calculate_average_bill(payments, sessions)
    total_customers = sessions.sum(:party_size)
    return 0 if total_customers.zero?

    (payments.sum(:amount).to_f / total_customers).round
  end

  # ========================================
  # TOP商品を取得
  # ========================================
  def top_menu_items(date, limit: 10)
    OrderItem.joins(order: { table_session: :payment })
             .where(payments: {
               store: @store,
               status: :completed
             })
             .where('payments.paid_at >= ? AND payments.paid_at < ?',
                    date.beginning_of_day, date.end_of_day)
             .group(:menu_item_id, :menu_item_name)
             .select('menu_item_id,
                      menu_item_name,
                      SUM(quantity) as total_quantity,
                      SUM(unit_price * quantity) as total_sales')
             .order('total_sales DESC')
             .limit(limit)
             .map { |item|
               {
                 menu_item_id: item.menu_item_id,
                 name: item.menu_item_name,
                 quantity: item.total_quantity,
                 sales: item.total_sales
               }
             }
  end

  # ========================================
  # 時間帯別売上を取得
  # ========================================
  def hourly_sales(date)
    payments = completed_payments_for_date(date)

    (0..23).map do |hour|
      hour_start = date.beginning_of_day + hour.hours
      hour_end = hour_start + 1.hour

      hour_payments = payments.where('paid_at >= ? AND paid_at < ?', hour_start, hour_end)

      {
        hour: hour,
        sales: hour_payments.sum(:amount),
        count: hour_payments.count
      }
    end
  end

  # ========================================
  # 日別内訳を取得
  # ========================================
  def daily_breakdown(start_date, end_date)
    (start_date..end_date).map do |date|
      payments = completed_payments_for_date(date)

      {
        date: date,
        sales: payments.sum(:amount),
        payment_count: payments.count
      }
    end
  end

  # ========================================
  # 期間別売上合計を取得
  # ========================================
  def total_sales_for_range(start_date, end_date)
    @store.payments
          .completed
          .where('paid_at >= ? AND paid_at < ?',
                 start_date.beginning_of_day, end_date.end_of_day)
          .sum(:amount)
  end

  # ========================================
  # 期間別支払件数を取得
  # ========================================
  def payment_count_for_range(start_date, end_date)
    @store.payments
          .completed
          .where('paid_at >= ? AND paid_at < ?',
                 start_date.beginning_of_day, end_date.end_of_day)
          .count
  end
end
