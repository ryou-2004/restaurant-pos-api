class KitchenQueue < ApplicationRecord
  # ========================================
  # Concerns
  # ========================================
  include Tenantable

  # ========================================
  # 関連付け
  # ========================================
  belongs_to :store
  belongs_to :tenant
  belongs_to :order

  # ========================================
  # Enum定義
  # ========================================
  enum :status, {
    waiting: 0,      # 待機中
    in_progress: 1,  # 調理中
    completed: 2,    # 完了
    cancelled: 3     # キャンセル
  }

  # ========================================
  # バリデーション
  # ========================================
  validates :status, presence: true
  validates :priority, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # ========================================
  # スコープ
  # ========================================
  scope :active, -> { where(status: [:waiting, :in_progress]) }
  scope :by_priority, -> { order(priority: :desc, created_at: :asc) }

  # ========================================
  # パブリックメソッド
  # ========================================

  def start_cooking!
    return false unless waiting?

    update(status: :in_progress, started_at: Time.current)
    order.cooking!
    true
  end

  def mark_as_completed!
    return false unless in_progress?

    update(status: :completed, completed_at: Time.current)
    order.ready!
    true
  end

  def cooking_time_minutes
    return 0 unless started_at && completed_at

    ((completed_at - started_at) / 60).round
  end

  # 注文からキューを作成
  def self.create_from_order(order)
    create!(
      store: order.store,
      tenant: order.tenant,
      order: order,
      status: :waiting,
      priority: 0,
      estimated_cooking_time: estimate_cooking_time(order)
    )
  end

  private

  def self.estimate_cooking_time(order)
    order.order_items.count * 5
  end
end
