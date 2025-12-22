class StaffUser < ApplicationRecord
  has_secure_password

  enum :role, {
    support_staff: 0,
    system_admin: 1
  }

  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8 }, allow_nil: true

  before_validation :normalize_email

  def system_admin?
    role == 'system_admin'
  end

  private

  def normalize_email
    self.email = email&.downcase&.strip
  end
end
