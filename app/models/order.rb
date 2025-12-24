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
  has_many :order_items, dependent: :destroy
  has_one :kitchen_queue, dependent: :destroy
  has_one :payment, dependent: :destroy

  # ネストされた属性の受け入れ
  accepts_nested_attributes_for :order_items, allow_destroy: true

  # ========================================
  # Enum定義
  # ========================================
  enum :status, {
    pending: 0,    # 注文受付済み
    cooking: 1,    # 調理中
    ready: 2,      # 調理完了
    delivered: 3,  # 配膳済み
    paid: 4        # 会計済み
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
  scope :active, -> { where.not(status: :paid) }
  scope :today, -> { where('created_at >= ?', Time.current.beginning_of_day) }
  scope :by_table, ->(table_id) { where(table_id: table_id) }

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

  def can_pay?
    delivered?
  end

  private

  def generate_order_number
    date_prefix = Time.current.strftime('%Y%m%d')
    last_number = tenant.orders.where('order_number LIKE ?', "#{date_prefix}%").count
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
