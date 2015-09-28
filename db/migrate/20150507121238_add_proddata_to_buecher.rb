class AddProddataToBuecher < ActiveRecord::Migration
  def change
  	add_column :buecher, :format_id, :integer
  	add_column :buecher, :bindung_id, :integer
  	add_column :buecher, :umschlag_id, :integer
  	add_column :buecher, :papier_id, :integer
  end
end
