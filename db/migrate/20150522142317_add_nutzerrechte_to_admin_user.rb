class AddNutzerrechteToAdminUser < ActiveRecord::Migration
  def change
  	add_column :admin_users, :nutzerrechte_id, :integer, default:0
  end
end
