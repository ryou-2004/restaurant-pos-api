class Subscription < ApplicationRecord
  # ========================================
  # 関連付け
  # ========================================
  belongs_to :tenant

  # ========================================
  # Enum定義
  # ========================================
  enum :plan, {
    basic: 0,        # ベーシックプラン：手動リロード
    standard: 1,     # スタンダードプラン：3-5秒ポーリング
    enterprise: 2    # エンタープライズプラン：WebSocketリアルタイム
  }

  # ========================================
  # バリデーション
  # ========================================
  validates :plan, presence: true
  validates :max_stores, presence: true,
                         numericality: { only_integer: true, greater_than: 0 }

  # ========================================
  # コールバック
  # ========================================
  after_initialize :set_defaults, if: :new_record?

  # ========================================
  # パブリックメソッド
  # ========================================

  def active?
    expires_at.nil? || expires_at > Time.current
  end

  def expired?
    !active?
  end

  def can_create_order?
    active?
  end

  private

  def set_defaults
    case plan
    when 'basic'
      self.realtime_enabled = false
      self.polling_enabled = false
      self.max_stores ||= 1
    when 'standard'
      self.realtime_enabled = false
      self.polling_enabled = true
      self.max_stores ||= 20
    when 'enterprise'
      self.realtime_enabled = true
      self.polling_enabled = true
      self.max_stores ||= 999
    end
  end
end
