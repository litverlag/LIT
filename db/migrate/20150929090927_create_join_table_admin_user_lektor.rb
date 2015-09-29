class CreateJoinTableAdminUserLektor < ActiveRecord::Migration
  def change
    create_join_table :admin_users, :lektoren do |t|
       t.index [:admin_user_id, :lektor_id]
       t.index [:lektor_id, :admin_user_id]
    end
  end
end
