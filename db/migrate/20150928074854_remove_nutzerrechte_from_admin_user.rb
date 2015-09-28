class RemoveNutzerrechteFromAdminUser < ActiveRecord::Migration
  def change
  	remove_column :admin_users, :nutzerrechte_id
  end
end
