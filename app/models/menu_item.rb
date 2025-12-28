class MenuItem < ApplicationRecord
  # ========================================
  # Concerns
  # ========================================
  include Tenantable

  # ========================================
  # 関連付け
  # ========================================
  has_many :order_items, dependent: :restrict_with_error

  # ========================================
  # バリデーション
  # ========================================
  validates :name, presence: true, length: { maximum: 100 }
  validates :price, presence: true,
                    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :category, presence: true
  validates :category_order, presence: true,
                             numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # ========================================
  # スコープ
  # ========================================
  scope :available, -> { where(available: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :ordered_by_category, -> { order(:category_order, :category, :name) }

  # ========================================
  # パブリックメソッド
  # ========================================

  def price_with_tax(tax_rate = 0.10)
    (price * (1 + tax_rate)).round
  end
end
