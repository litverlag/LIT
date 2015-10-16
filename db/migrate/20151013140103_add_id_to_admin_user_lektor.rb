class AddIdToAdminUserLektor < ActiveRecord::Migration
  def change
    add_column :admin_users_lektoren, :id, :primary_key
  end
end
