class CreateJoinTableAdminUserDepartment < ActiveRecord::Migration
  def change
    create_join_table :admin_users, :departments do |t|
      # t.index [:admin_user_id, :department_id]
      # t.index [:department_id, :admin_user_id]
    end
  end
end
