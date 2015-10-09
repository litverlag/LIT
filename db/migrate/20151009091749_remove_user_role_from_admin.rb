class RemoveUserRoleFromAdmin < ActiveRecord::Migration
  def change
      remove_column :admin_users, :user_role
  end
end
