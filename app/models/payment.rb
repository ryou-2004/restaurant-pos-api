class Payment < ApplicationRecord
  # ========================================
  # Concerns
  # ========================================
  include Tenantable

  # ========================================
  # 関連付け
  # ========================================
  belongs_to :order

  # ========================================
  # Enum定義
  # ========================================
  enum :payment_method, {
    cash: 0,         # 現金
    credit_card: 1,  # クレジットカード
    qr_code: 2,      # QRコード決済
    electronic: 3    # 電子マネー
  }

  enum :status, {
    pending: 0,    # 未払い
    completed: 1,  # 支払い完了
    failed: 2,     # 支払い失敗
    refunded: 3    # 返金済み
  }

  # ========================================
  # バリデーション
  # ========================================
  validates :payment_method, presence: true
  validates :amount, presence: true,
                    numericality: { only_integer: true, greater_than: 0 }
  validates :status, presence: true

  # ========================================
  # コールバック
  # ========================================
  after_update :mark_order_as_paid, if: :saved_change_to_status?

  # ========================================
  # スコープ
  # ========================================
  scope :completed, -> { where(status: :completed) }
  scope :today, -> { where('created_at >= ?', Time.current.beginning_of_day) }

  # ========================================
  # パブリックメソッド
  # ========================================

  def mark_as_completed!
    update(status: :completed, paid_at: Time.current)
  end

  def mark_as_failed!
    update(status: :failed)
  end

  private

  def mark_order_as_paid
    order.paid! if completed? && order.delivered?
  end
end
