class AddUserRolesToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :user_role, :string, :null false
  end
end
