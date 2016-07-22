class CreateReihen < ActiveRecord::Migration
  def change
    create_table :reihen do |t|
      t.string :name
      t.string :r_code
      t.string :issn	#Should only be in 'reihen' db.

      t.timestamps null: false
    end
  end
end
