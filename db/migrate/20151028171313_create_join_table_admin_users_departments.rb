class CreateJoinTableAdminUsersDepartments < ActiveRecord::Migration
  def change
  	create_join_table :admin_users, :departments
  end
end
