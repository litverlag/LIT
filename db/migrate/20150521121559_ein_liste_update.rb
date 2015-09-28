class EinListeUpdate < ActiveRecord::Migration
  def change
  	add_column :ein_listes, :Rueckenfrei, :string
  	add_column :ein_listes, :SollF_Um, :string
  end
end
