class Current < ActiveSupport::CurrentAttributes
  attribute :tenant, :user, :staff_user
end
