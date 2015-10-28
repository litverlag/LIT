class CreateReihen < ActiveRecord::Migration
  def change
    create_table :reihen do |t|
      t.string :name
      t.string :r_code

      t.timestamps null: false
    end
  end
end
