class AddUserRolesToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :user_role, :string
  end
end
