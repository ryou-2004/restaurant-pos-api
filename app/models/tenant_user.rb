class TenantUser < ApplicationRecord
  has_secure_password
  belongs_to :tenant
  has_many :tenant_user_tags, dependent: :destroy
  has_many :tags, through: :tenant_user_tags

  enum :role, {
    owner: 0,
    manager: 1,
    staff: 2,
    kitchen_staff: 3,
    cashier: 4
  }

  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: { scope: :tenant_id, case_sensitive: false }
  validates :password, length: { minimum: 8 }, allow_nil: true

  before_validation :normalize_email

  def can_access_tenant_dashboard?
    owner? || manager?
  end

  def can_manage_menu?
    owner? || manager?
  end

  def can_manage_staff?
    owner?
  end

  private

  def normalize_email
    self.email = email&.downcase&.strip
  end
end
