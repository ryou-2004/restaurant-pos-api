class Tag < ApplicationRecord
  # ========================================
  # 関連付け
  # ========================================
  belongs_to :tenant
  has_many :tenant_user_tags, dependent: :destroy
  has_many :tenant_users, through: :tenant_user_tags

  # ========================================
  # バリデーション
  # ========================================
  validates :name, presence: true, length: { maximum: 50 }
  validates :name, uniqueness: { scope: :tenant_id, message: 'は同じテナント内で既に使用されています' }
end
