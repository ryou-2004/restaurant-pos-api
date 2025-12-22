class Tenant < ApplicationRecord
  # ========================================
  # 関連付け
  # ========================================
  has_one :subscription, dependent: :destroy
  has_many :users, dependent: :destroy

  # ========================================
  # バリデーション
  # ========================================
  validates :name, presence: true, length: { maximum: 255 }
  validates :subdomain, presence: true,
                        uniqueness: { case_sensitive: false },
                        format: { with: /\A[a-z0-9-]+\z/, message: '半角英数字とハイフンのみ使用できます' },
                        length: { minimum: 3, maximum: 63 }

  # ========================================
  # コールバック
  # ========================================
  before_validation :normalize_subdomain

  # ========================================
  # パブリックメソッド
  # ========================================

  def realtime_enabled?
    subscription&.realtime_enabled? || false
  end

  def polling_enabled?
    subscription&.polling_enabled? || false
  end

  private

  def normalize_subdomain
    self.subdomain = subdomain&.downcase&.strip
  end
end
