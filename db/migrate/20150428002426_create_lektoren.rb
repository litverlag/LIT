class CreateLektoren < ActiveRecord::Migration
  def change
    create_table :lektoren do |t|
      t.string :name
      t.string :titel
      t.string :position
      t.string :emailkuerzel
      t.string :fox_name

      t.timestamps null: false
    end
  end
end
