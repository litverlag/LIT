class AddingColumnsToProd < ActiveRecord::Migration
  def change
  	add_column :gprods, :um_sollf, :date
  	add_column :gprods, :um_verschickt, :date
  	add_column :gprods, :klapptext, :text
  	add_column :gprods, :um_frei, :string
  	add_column :gprods, :um_warten, :string
  	add_column :gprods, :rueckenfrei, :string
  end
end