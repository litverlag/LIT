class CreateBindungen < ActiveRecord::Migration
  def change
    create_table :bindungen do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
