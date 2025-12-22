class OrderItem < ApplicationRecord
  # ========================================
  # 関連付け
  # ========================================
  belongs_to :order
  belongs_to :menu_item

  # ========================================
  # バリデーション
  # ========================================
  validates :quantity, presence: true,
                      numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, presence: true,
                        numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # ========================================
  # コールバック
  # ========================================
  before_validation :set_unit_price, on: :create

  # ========================================
  # パブリックメソッド
  # ========================================

  def subtotal
    unit_price * quantity
  end

  def menu_item_name
    menu_item&.name
  end

  private

  def set_unit_price
    self.unit_price ||= menu_item&.price
  end
end
