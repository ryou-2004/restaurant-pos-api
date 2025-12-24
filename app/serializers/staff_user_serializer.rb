# Staff認証レスポンス用シリアライザー
class StaffUserSerializer
  def initialize(staff_user)
    @staff_user = staff_user
  end

  def as_json(options = {})
    {
      id: @staff_user.id,
      name: @staff_user.name,
      email: @staff_user.email,
      role: @staff_user.role,
      user_type: 'staff'
    }
  end
end
