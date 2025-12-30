class PrintLog < ApplicationRecord
  # ========================================
  # 関連付け
  # ========================================
  belongs_to :tenant
  belongs_to :store
  belongs_to :order
  belongs_to :print_template, optional: true

  # ========================================
  # Enum定義
  # ========================================
  enum :status, {
    success: 'success',
    failed: 'failed',
    cancelled: 'cancelled'
  }, _prefix: true

  # ========================================
  # バリデーション
  # ========================================
  validates :printed_at, presence: true
  validates :status, presence: true

  # ========================================
  # スコープ
  # ========================================
  scope :recent, -> { order(printed_at: :desc) }
  scope :succeeded, -> { status_success }
  scope :failed_logs, -> { status_failed }
  scope :for_order, ->(order) { where(order: order) }
  scope :today, -> { where('printed_at >= ?', Time.current.beginning_of_day) }

  # ========================================
  # パブリックメソッド
  # ========================================

  # 印刷成功かどうか
  def success?
    status == 'success'
  end

  # エラーメッセージがあるか
  def has_error?
    error_message.present?
  end
end
