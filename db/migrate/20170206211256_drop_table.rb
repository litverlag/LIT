class DropTable < ActiveRecord::Migration[5.0]
  def change
    drop_table :active_admin_comments
    drop_table :admin_users
    drop_table :admin_users_departments
  end
end
