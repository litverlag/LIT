class CreateReihenHgZuordnungen < ActiveRecord::Migration
  def change
    create_table :reihen_hg_zuordnungen do |t|
      t.integer :reihe_id
      t.integer :autor_id
      t.integer :frei_ex

      t.timestamps null: false
    end
  end
end
