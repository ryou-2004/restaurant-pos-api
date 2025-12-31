class Order < ApplicationRecord
  # ========================================
  # Concerns
  # ========================================
  include Tenantable

  # ========================================
  # 関連付け
  # ========================================
  belongs_to :store
  belongs_to :tenant
  belongs_to :table_session, optional: true
  has_many :order_items, dependent: :destroy
  has_one :kitchen_queue, dependent: :destroy
  has_many :print_logs, dependent: :destroy

  # ネストされた属性の受け入れ
  accepts_nested_attributes_for :order_items, allow_destroy: true

  # ========================================
  # Enum定義
  # ========================================
  enum :status, {
    pending: 0,    # 注文受付済み
    cooking: 1,    # 調理中
    ready: 2,      # 調理完了
    delivered: 3   # 配膳済み
    # 注意: 'paid' は削除。会計はTableSessionとPaymentで管理
  }

  # ========================================
  # バリデーション
  # ========================================
  validates :order_number, presence: true,
                          uniqueness: { scope: :store_id }
  validates :status, presence: true
  validates :total_amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # ========================================
  # コールバック
  # ========================================
  before_validation :generate_order_number, on: :create
  after_update :broadcast_status_change, if: :saved_change_to_status?

  # ========================================
  # スコープ
  # ========================================
  scope :today, -> { where('created_at >= ?', Time.current.beginning_of_day) }
  scope :by_table, ->(table_id) { where(table_id: table_id) }
  scope :by_session, ->(session_id) { where(table_session_id: session_id) }
  scope :active, -> { where(cancelled_at: nil) }
  scope :cancelled, -> { where.not(cancelled_at: nil) }

  # ========================================
  # パブリックメソッド
  # ========================================

  def calculate_total
    order_items.sum(&:subtotal)
  end

  def item_count
    order_items.sum(:quantity)
  end

  def can_start_cooking?
    pending?
  end

  def can_mark_as_ready?
    cooking?
  end

  def can_deliver?
    ready?
  end

  # キャンセル可能かチェック（調理前のみ）
  def can_cancel?
    pending? && !cancelled?
  end

  # キャンセル済みかチェック
  def cancelled?
    cancelled_at.present?
  end

  # 注文をキャンセル
  def cancel!(reason)
    raise StandardError, 'この注文はキャンセルできません' unless can_cancel?

    update!(
      cancelled_at: Time.current,
      cancellation_reason: reason
    )
  end

  private

  def generate_order_number
    date_prefix = Time.current.strftime('%Y%m%d')
    # 店舗ごとに注文番号を採番（同じ店舗内で一意）
    last_number = store.orders.where('order_number LIKE ?', "#{date_prefix}%").count
    self.order_number = "#{date_prefix}-#{(last_number + 1).to_s.rjust(3, '0')}"
  end

  def broadcast_status_change
    return unless tenant.realtime_enabled?

    ActionCable.server.broadcast(
      "tenant_#{tenant_id}_orders",
      {
        type: 'order_updated',
        order: { id: id, status: status, updated_at: updated_at }
      }
    )
  end
end
