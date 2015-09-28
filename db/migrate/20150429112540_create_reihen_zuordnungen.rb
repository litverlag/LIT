class CreateReihenZuordnungen < ActiveRecord::Migration
  def change
    create_table :reihen_zuordnungen do |t|
      t.integer :buch_id
      t.integer :reihe_id

      t.timestamps null: false
    end
  end
end
