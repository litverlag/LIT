class UpdateEinListe < ActiveRecord::Migration
  def change
  	 add_column :ein_listes, :Name, :string
  	 add_column :ein_listes, :SollF_Tit, :string
  	 add_column :ein_listes, :Eintrag, :string
  	 add_column :ein_listes, :Versand, :string
  	 add_column :ein_listes, :Verschickt, :string
  	 add_column :ein_listes, :Ruecken, :string
  	 add_column :ein_listes, :Warten, :string
  	 add_column :ein_listes, :Besonderheit, :string
  	 add_column :ein_listes, :Frei, :string
  	 add_column :ein_listes, :Klapptext, :string
  	 add_column :ein_listes, :Bild, :string
  	 add_column :ein_listes, :Korrektur, :string
  	 add_column :ein_listes, :Freigabe, :string
  	 add_column :ein_listes, :Erscheinungsjahr, :string
  	 add_column :ein_listes, :Bemerkungen, :string
  	 add_column :ein_listes, :Bemerkungen_2, :string
  	 add_column :ein_listes, :stand, :string
  end
end
