class CreateBuecher < ActiveRecord::Migration
  def change
    create_table :buecher do |t|

      #Association Attribute
      t.belongs_to :autor
      t.belongs_to :lektor
      t.belongs_to :gprod

      #Normale Attribute
      t.string :name
      t.string :isbn
      #t.string :issn	#Should only be in 'reihen' db.
      t.text :titel1
      t.text :titel2
      t.text :titel3
      t.text :utitel1
      t.text :utitel2
      t.text :utitel3
      t.integer :seiten
      t.decimal :preis, precision: 4, scale: 2
      t.decimal :spreis, precision: 4, scale: 2
      t.boolean :sammelband, default: false
      t.date :erscheinungsjahr #TODO nur ausfüllen wenn bestimmtes Erscheinungsjahr gewünscht
      t.float :gewicht
      t.float :volumen


      t.string :format_bezeichnung
      t.string :umschlag_bezeichnung
      t.string :papier_bezeichnung
      t.string :bindung_bezeichnung


      t.string :vier_farb
      t.float :rueckenstaerke
      t.boolean :klappentext
      t.boolean :eintrag_cip_seite
      t.timestamps null: false
    end
  end
end
