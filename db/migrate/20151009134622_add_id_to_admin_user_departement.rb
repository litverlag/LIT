class AddIdToAdminUserDepartement < ActiveRecord::Migration
  #
  def change
      add_column :admin_users_departments, :id, :primary_key
  end
end
