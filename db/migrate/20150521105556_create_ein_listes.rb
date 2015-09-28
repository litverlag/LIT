class CreateEinListes < ActiveRecord::Migration
  def change
    create_table :ein_listes do |t|
      t.string :ISBN
      t.string :Auflage
      t.string :Prio
      t.string :Druck
      t.string :MsEin
      t.string :SollF
      t.string :Lek
      t.string :Korr
      t.string :Format
      t.string :Date #Rename Datei
      t.string :Seiten
      t.string :Reihe
      t.string :Titelei
      t.string :Form
      t.string :Papier
      t.string :Umschlag
      t.string :Satz
      t.string :vf
      t.string :email
      t.string :Sonder

      t.timestamps null: false
    end
  end
end
