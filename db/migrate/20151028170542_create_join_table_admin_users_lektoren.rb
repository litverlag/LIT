class CreateJoinTableAdminUsersLektoren < ActiveRecord::Migration
  def change
  	create_join_table :admin_users, :lektoren
  end
end
