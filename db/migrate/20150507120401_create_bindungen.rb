class CreateBindungen < ActiveRecord::Migration
  def change
    create_table :bindungen do |t|
    	#Association Attribute
    	t.belongs_to :buch

    	#Allgemeine Attribute
      t.string :bezeichnung

      t.timestamps null: false
    end
  end
end
