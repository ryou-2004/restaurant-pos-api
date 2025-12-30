class Payment < ApplicationRecord
  # ========================================
  # Concerns
  # ========================================
  include Tenantable

  # ========================================
  # 関連付け
  # ========================================
  belongs_to :table_session

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
  after_update :complete_table_session, if: :saved_change_to_status?

  # ========================================
  # スコープ
  # ========================================
  scope :completed, -> { where(status: :completed) }
  scope :today, -> { where('paid_at >= ?', Time.current.beginning_of_day) }

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

  def complete_table_session
    # 支払いが完了したらテーブルセッションを完了状態にする
    table_session.complete! if completed? && table_session.active?
  end
end
