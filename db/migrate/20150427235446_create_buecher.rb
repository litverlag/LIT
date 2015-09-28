class CreateBuecher < ActiveRecord::Migration
  def change
    create_table :buecher do |t|
      t.text :name
      t.string :isbn
      t.string :issn
      t.text :titel1
      t.text :titel2
      t.text :titel3
      t.text :utitel1
      t.text :utitel2
      t.text :utitel3
      t.integer :seiten
      t.decimal :preis, precision: 4, scale: 2
      t.decimal :spreis, precision: 4, scale: 2
      t.boolean :sammelband

      t.timestamps null: false
    end
  end
end
