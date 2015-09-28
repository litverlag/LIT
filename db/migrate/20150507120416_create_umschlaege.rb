class CreateUmschlaege < ActiveRecord::Migration
  def change
    create_table :umschlaege do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
