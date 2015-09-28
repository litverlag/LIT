class CreatePapiere < ActiveRecord::Migration
  def change
    create_table :papiere do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
