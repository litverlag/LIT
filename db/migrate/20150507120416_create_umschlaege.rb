class CreateUmschlaege < ActiveRecord::Migration
  def change
    create_table :umschlaege do |t|
    	#Association Attribute
    	t.belongs_to :buch

    	#Allgemeine Attribute
      t.string :bezeichnung
      t.string :kaschierung
      t.boolean :leinenumschlag

      t.timestamps null: false
    end
  end
end
