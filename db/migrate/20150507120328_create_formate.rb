class CreateFormate < ActiveRecord::Migration
  def change
    create_table :formate do |t|
    	#Association Attribute
    	t.belongs_to :buch

    	#Allgemeine Attribute
      t.string :bezeichnung

      t.timestamps null: false
    end
  end
end
