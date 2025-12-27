class TenantUserTag < ApplicationRecord
  # ========================================
  # 関連付け
  # ========================================
  belongs_to :tenant_user
  belongs_to :tag

  # ========================================
  # バリデーション
  # ========================================
  validates :tenant_user_id, uniqueness: { scope: :tag_id, message: 'には同じタグを複数回付与できません' }
end
