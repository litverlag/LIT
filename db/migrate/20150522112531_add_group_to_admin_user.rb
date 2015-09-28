class AddGroupToAdminUser < ActiveRecord::Migration
  def change
  	 add_column :admin_users, :group_id, :integer, default:0
  end
end
