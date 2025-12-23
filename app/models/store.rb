class Store < ApplicationRecord
  # ========================================
  # 関連付け
  # ========================================
  belongs_to :tenant
  has_many :orders, dependent: :destroy
  has_many :kitchen_queues, dependent: :destroy
  has_many :menu_items, through: :tenant

  # ========================================
  # バリデーション
  # ========================================
  validates :name, presence: true, length: { maximum: 255 }
  validates :name, uniqueness: { scope: :tenant_id, message: 'は同じテナント内で既に使用されています' }
  validates :phone, format: { with: /\A[\d-]+\z/, message: 'は数字とハイフンのみ使用できます', allow_blank: true }

  # ========================================
  # スコープ
  # ========================================
  scope :active, -> { where(active: true) }
end
