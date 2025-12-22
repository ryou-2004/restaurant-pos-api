class User < ApplicationRecord
  # ========================================
  # セキュリティ
  # ========================================
  has_secure_password

  # ========================================
  # 関連付け
  # ========================================
  belongs_to :tenant

  # ========================================
  # Enum定義
  # ========================================
  enum :role, {
    staff: 0,     # 一般スタッフ：注文入力、配膳
    manager: 1,   # マネージャー：売上確認、レポート
    admin: 2      # 管理者：全権限
  }

  # ========================================
  # バリデーション
  # ========================================
  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: { scope: :tenant_id, case_sensitive: false }
  validates :password, length: { minimum: 8 }, allow_nil: true

  # ========================================
  # コールバック
  # ========================================
  before_validation :normalize_email

  # ========================================
  # パブリックメソッド
  # ========================================

  def admin?
    role == 'admin'
  end

  def manager_or_admin?
    manager? || admin?
  end

  private

  def normalize_email
    self.email = email&.downcase&.strip
  end
end
