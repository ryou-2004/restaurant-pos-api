class RenameUsersToTenantUsers < ActiveRecord::Migration[8.0]
  def change
    rename_table :users, :tenant_users
  end
end
