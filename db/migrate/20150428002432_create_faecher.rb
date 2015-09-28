class CreateFaecher < ActiveRecord::Migration
  def change
    create_table :faecher do |t|
      t.string :name
      t.string :fox_name

      t.timestamps null: false
    end
  end
end
